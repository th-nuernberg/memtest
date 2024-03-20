//
//  AudioCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI
import AudioKit
import SwiftWhisper

struct AudioCalibrationView: View {
    @State var showNextView: Bool = false
    @State private var transcription: String = "Transcription will appear here"
    
    var body: some View {
        NavigationStack {
            VStack{
                
                
                
                
                
                Text(transcription) // Display the transcription result
                
                Button("Transcribe") {
                    Task {
                        await transcribeAudio()
                    }
                }
                
                
                Button{
                    showNextView.toggle()
                }label: {
                    Text("Zur nächsten View")
                }
                .navigationDestination(isPresented: $showNextView) {
                    Test1View()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func transcribeAudio() async {
        guard let modelURL = Bundle.main.url(forResource: "models/ggml-small", withExtension: "bin"),
              let audioFileURL = Bundle.main.url(forResource: "samples/Neue Aufnahme 30", withExtension: "m4a") else {
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

#Preview {
    AudioCalibrationView()
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
