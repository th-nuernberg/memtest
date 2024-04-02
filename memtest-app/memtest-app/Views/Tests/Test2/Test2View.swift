//
//  Test2View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test2View: View {
    
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false
    
    private var symbolList = TestSymbolList()
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, destination: {LearnphaseView()}, content: {
            Text(manager.recognizedWords.last ?? "")
            
            LazyVGrid(columns: columns) {
                ForEach(symbolList.symbols, id: \.name) { symbol in
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                            .frame(width: 200)
                            .cornerRadius(20)
                            .padding(.bottom, 20)
                        
                        Image(symbol.fileUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .offset(x: 5, y: -5)
                            .opacity(self.isSymbolNameRecognized(symbol.name) ? 1 :0)
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
            .onTimerComplete(duration: 5) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
                
                // TODO: route to Test2View
            }
        }, explanationContent: {
            HStack {
                HStack {
                    ForEach(0..<3) { index in
                        ZStack {
                            if index == 1 {
                                Circle()
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                Text("2")
                                    .font(.title)
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding(.trailing, 5)
                    }
                }
                
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
                HStack {
                    ForEach(0..<3) { _ in
                        Circle()
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                            .padding(.leading, 5)
                    }
                }
            }
            
            HStack {
                Text("Aufgabenstellung 2")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre zweite Aufgabe besteht darin, die Bilder die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("ihnen gerade gezeigt wurden, noch einmal")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("noch einmal zu bennen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Zum Beispiel haben wir ihnen vorhin ein Bild")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("Baums gezeigt, dann sagen Sie jetzt Baum.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Das erkannte Objekte wird dann automatisch angezeigt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 2, onContinue: onContinue)
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
    Test2View()
}
