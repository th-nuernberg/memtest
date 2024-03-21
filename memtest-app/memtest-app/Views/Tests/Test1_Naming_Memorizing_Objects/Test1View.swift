//
//  Test1View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test1View: View {
    @ObservedObject private var manager = SpeechRecognitionManager()
    @State private var isRecording = false
    
    var body: some View {
        BaseTestView(destination: Test2View(), content: {
            
            VStack(spacing: 20) {
                Text(manager.recognizedText.isEmpty ? "Recognition text will appear here" : manager.recognizedText)
                    .padding()
                    .border(Color.gray, width: 1)
                
                Button(action: {
                    self.startStopRecording()
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                }
            }
            .padding()
            
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
    
    private func startStopRecording() {
        if isRecording {
            AudioService.shared.stopRecording {
                listRecordedFiles()
            }
        } else {
            do {
                try AudioService.shared.startRecording(to: "test1")
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
        isRecording.toggle()
    }

    private func listRecordedFiles() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            // Filter for specific file types if needed, e.g., .m4a
            let audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }
            print("Recorded files:")
            for file in audioFiles {
                print(file.lastPathComponent)
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
    
}





#Preview {
    Test1View()
}
