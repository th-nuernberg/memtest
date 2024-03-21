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
    
    private var symbolList = TestSymbolList()
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        Text(manager.recognizedWords.last ?? "")
        
        LazyVGrid(columns: columns) {
            ForEach(symbolList.symbols, id: \.name) { symbol in
                ZStack {
                    Rectangle()
                        .fill(self.isSymbolNameRecognized(symbol.name) ? Color.gray.opacity(0.5) : Color.gray) 
                        .frame(height: 200)
                        .frame(width: 200)
                        .cornerRadius(20)
                        .padding(.bottom, 20)
                    
                    Image(symbol.fileUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .offset(x: 5, y: -5)
                }
            }
        }
        .padding(.vertical)
        .padding(.top, 70)
        .onAppear(perform: {
            do {
                try AudioService.shared.startRecording(to: "test1")
            } catch {
                print("Failed to start recording: \(error)")
            }
        })
    }
    
    private func isSymbolNameRecognized(_ name: String) -> Bool {
        return manager.recognizedWords.contains { $0.lowercased().contains(name.lowercased()) }
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
