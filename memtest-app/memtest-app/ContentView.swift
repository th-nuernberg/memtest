//
//  ContentView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 22.02.24.
//

import SwiftUI
import AudioKit
import SwiftWhisper

import AVFoundation

class AudioTranscriptor: ObservableObject {
    let audioEngine = AVAudioEngine()
    let whisper: Whisper // Assume this is your wrapper around the Whisper model
    
    @Published var isTranscribing = false
    @Published var transcription = "Transcription will appear here"
    
    private var audioBuffer = [Float]()
    private let sampleRate: Double = 16000 // Expected sample rate for Whisper
    private var bufferCapacity: Int {
        return Int(sampleRate * 2) // 5 seconds of audio
    }
    private var overlapCapacity: Int {
        return Int(sampleRate * 0.1) // 0.5 seconds of overlap
    }
    
    init(whisper: Whisper) {
        self.whisper = whisper
    }

    private func startTranscribing() {
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
    
    private func stopTranscribing() {
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

struct ContentView: View {
    var whisper: Whisper
    var transcriptor: AudioTranscriptor
    @State private var transcription: String = "Transcription will appear here"
    
    init() {
        let modelURL = Bundle.main.url(forResource: "ggml-small", withExtension: "bin")!
    
        self.whisper = Whisper(fromFileURL: modelURL)
        self.whisper.params.language = WhisperLanguage.german
        self.whisper.params.print_progress = false
        //self.whisper.params.print_realtime = true
        self.transcriptor = AudioTranscriptor(whisper: self.whisper)
    }
    
    var body: some View {
        NavigationStack {
            VStack{

                Text(transcriptor.transcription) // Display the transcription result
                
                Button("Transcribe") {
                    self.transcriptor.toggleTranscribing()
                }
                
            }
        }
    }
    
    func transcribeAudio() async {
       guard let modelURL = Bundle.main.url(forResource: "ggml-tiny", withExtension: "bin"),
             let audioFileURL = Bundle.main.url(forResource: "Neue Aufnahme 30", withExtension: "m4a") else {
           print(Bundle.main)
                 print("Error: Unable to find model or audio file.")
                 return
             }
       
       do {
           let audioFrames = try await convertAudioFileToPCMArrayAsync(fileURL: audioFileURL)
           let whisper = try Whisper(fromFileURL: modelURL)
           
           let segments = try await whisper.transcribe(audioFrames: audioFrames)
           DispatchQueue.main.async {
               self.transcription = "Transcribed audio: " + segments.map(\.text).joined(separator: " ")
           }
       } catch {
           print("Error during transcription or conversion: \(error)")
       }
   }
    
    
    func convertAudioFileToPCMArrayAsync(fileURL: URL) async throws -> [Float] {
            try await withCheckedThrowingContinuation { continuation in
                convertAudioFileToPCMArray(fileURL: fileURL) { result in
                    switch result {
                    case .success(let audioFrames):
                        continuation.resume(returning: audioFrames)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
   
}

func convertAudioFileToPCMArray(fileURL: URL, completionHandler: @escaping (Result<[Float], Error>) -> Void) {
    var options = FormatConverter.Options()
    options.format = .wav
    options.sampleRate = 16000
    options.bitDepth = 16
    options.channels = 1
    options.isInterleaved = false

    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    let converter = FormatConverter(inputURL: fileURL, outputURL: tempURL, options: options)
    converter.start { error in
        if let error {
            completionHandler(.failure(error))
            return
        }

        let data = try! Data(contentsOf: tempURL) // Handle error here

        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }

        try? FileManager.default.removeItem(at: tempURL)

        completionHandler(.success(floats))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgbValue = UInt32(hex, radix: 16)
        let r = Double((rgbValue! & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue! & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue! & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

/*
#Preview {
    ContentView()
}*/
