//
//  WhisperTranscriptionService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.04.24.
//
// This Service is currently not used because of optimization that is needed to properly let it run on device

import Foundation
import AudioKit
import SwiftWhisper
import AVFoundation

class WhisperTranscriptionService: TranscriptionService {
    let audioEngine = AVAudioEngine()
    let whisper: Whisper
    
    
    var onTranscriptionUpdate: ((String) -> Void)?
    
    @Published var isTranscribing = false
    @Published var transcription = ""
    
    private var audioBuffer = [Float]()
    // Sample Rate has to be 160000 for whisper.cpp
    private let targetSampleRate: Double = 16000
    private var bufferCapacity: Int {
        return Int(targetSampleRate * 2)
    }
    private var overlapCapacity: Int {
        return Int(targetSampleRate * 0.1)
    }
    
    init() {
        
        let modelURL = Bundle.main.url(forResource: "ggml-small", withExtension: "bin")!
    
        let whisper = Whisper(fromFileURL: modelURL)
        whisper.params.language = WhisperLanguage.german
        whisper.params.print_progress = false
        whisper.params.no_context = false
        self.whisper = whisper
    }
    
    func startTranscribing() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Trying to set the sample Rate -> but setPreferredSampleRate() doesnt guarantee to set it
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
        
        // Note: the buffer size must not be set arbitrarily ->  the length of the buffer size has to be between 100ms and 400ms -> therefore it has to be computed with sample rate in mind
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: hwFormat) { [weak self] (buffer, when) in
            // because of the buffer size limitation we have to accumulate the buffer for whisper.cpp
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
    
    // this function is for conforming to the TranscriptionService protocol and is called in the AudioService
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Int, bufferSize: Int) {
        if isTranscribing {
            accumulateAudioBuffer(buffer, sampleRate: sampleRate, bufferSize: bufferSize)
        }
    }
    
    func startTranscribing() {
        isTranscribing = true
    }
    
    func stopTranscribing() {
        isTranscribing = false
    }
    
    public func toggleTranscribing() {
        if (!isTranscribing) {
            startTranscribing()
        } else {
            stopTranscribing()
            // reset audio buffer
            audioBuffer = []
        }
    }
    
    private func accumulateAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Int, bufferSize: Int) {
        guard let floatChannelData = buffer.floatChannelData else {
            print("Audio buffer data is nil")
            return
        }
        
        let frameLength = Int(buffer.frameLength)
    
        let channel = floatChannelData[0]
        
        
        var tmpBuffer: [Float] = [Float]()
        
        for i in 0..<frameLength {
            tmpBuffer.append(channel[i])
        }
        
        /*
         Not currently used 
        // Calculate the number of samples required for the targetSampleRate
        let targetSampleCount = Int(Double(tmpBuffer.count) * (targetSampleRate / Double(sampleRate)))
        
        // Downsample the buffer
        let downSampledBuffer = tmpBuffer.downSample(to: targetSampleCount)
        
        print(buffer.frameLength)
        print(downSampledBuffer.count)
         */
        
        audioBuffer.append(contentsOf: tmpBuffer)
        
        if audioBuffer.count >= bufferCapacity {
            transcribeAudioBuffer()
        }
    }
    
    private func transcribeAudioBuffer() {
        
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
                    
                    // Use callback for notification
                    self?.onTranscriptionUpdate?(fullTranscription)
                    
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
