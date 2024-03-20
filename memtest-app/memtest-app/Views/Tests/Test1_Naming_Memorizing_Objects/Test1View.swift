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
               SpeechRecognitionService.shared.stopRecording()
           } else {
               do {
                   try SpeechRecognitionService.shared.startRecording()
               } catch {
                   print("Failed to start recording: \(error)")
               }
           }
           isRecording.toggle()
       }
}





#Preview {
    Test1View()
}
