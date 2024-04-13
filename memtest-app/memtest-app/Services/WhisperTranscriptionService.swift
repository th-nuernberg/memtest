//
//  WhisperTranscriptionService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.04.24.
//

import Foundation
import AudioKit
import SwiftWhisper
import AVFoundation

class WhisperTranscriptionService: TranscriptionService {
    let audioEngine = AVAudioEngine()
    let whisper: Whisper
    
    
    var onTranscriptionUpdate: ((String) -> Void)?
    
    @Published var isTranscribing = false
    @Published var transcription = "Transcription will appear here"
    
    private var audioBuffer = [Float]()
    private let sampleRate: Double = 16000
    private var bufferCapacity: Int {
        return Int(sampleRate * 2)
    }
    private var overlapCapacity: Int {
        return Int(sampleRate * 0.1)
    }
    
    init() {
        
        let modelURL = Bundle.main.url(forResource: "ggml-tiny", withExtension: "bin")!
    
        let whisper = Whisper(fromFileURL: modelURL)
        whisper.params.language = WhisperLanguage.german
        whisper.params.print_progress = false
        //whisper.params.print_realtime = true
        
        self.whisper = whisper
    }

    func startTranscribing() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setPreferredSampleRate(sampleRate)
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session properties: \(error)")
            return
        }

        let hwSampleRate = audioSession.sampleRate
        let inputNode = audioEngine.inputNode
        let hwFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: hwSampleRate, channels: 1, interleaved: false)!
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: hwFormat) { [weak self] (buffer, when) in
            self?.accumulateAudioBuffer(buffer)
        }

        audioEngine.prepare()
        try! audioEngine.start()
    }
    
    func stopTranscribing() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioBuffer.removeAll()
        isTranscribing = false
    }
    
    public func toggleTranscribing() {
        if (!isTranscribing) {
            startTranscribing()
            isTranscribing = true
        } else {
            stopTranscribing()
        }
    }
    
    private func accumulateAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let floatChannelData = buffer.floatChannelData else {
            print("Audio buffer data is nil")
            return
        }
        
        let frameLength = Int(buffer.frameLength)
        let channel = floatChannelData[0]
        
        for i in 0..<frameLength {
            audioBuffer.append(channel[i])
        }
        
        if audioBuffer.count >= bufferCapacity {
            processAudioBuffer()
        }
    }
    
    private func processAudioBuffer() {
        if audioBuffer.count > bufferCapacity {
            let extraBuffer = Array(audioBuffer.dropFirst(bufferCapacity))
            audioBuffer.removeSubrange(bufferCapacity...)
            audioBuffer = extraBuffer
        }

        whisper.transcribe(audioFrames: audioBuffer) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let segments):
                    let fullTranscription = segments.map { $0.text }.joined(separator: " ")
                    self?.transcription = fullTranscription
                    
                    self?.onTranscriptionUpdate?(fullTranscription)
                    
                    print("Transcription: \(self?.transcription)")
                case .failure(let error):
                    self?.transcription = "Error transcribing audio: \(error.localizedDescription)"
                    print("Error transcribing audio: \(error)")
                }
            }
        }
        // Prepare buffer for next round, keep the last part of the buffer
        let startIndex = max(audioBuffer.count - overlapCapacity, 0)
        audioBuffer = Array(audioBuffer[startIndex...])
    }
}
