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
    private let testDuration = 60
    
    private var symbolList = TestSymbolList()
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 1,
                     textOfCircle:"2", destination: {LearnphaseView()}, content: {
            
            //Text(manager.recognizedWords.last ?? "")
            
            VStack{
                AudioIndicatorView()
                Spacer()
                HStack {
                    Spacer()
                    HourglassView(size: 200, duration: testDuration)
                    Spacer()
                }
                Spacer()
            }
            .onAppear(perform: {
                manager.recognizedWords = []
                do {
                    try AudioService.shared.startRecording(to: "test2")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: testDuration) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
            
            }
        }, explanationContent: {
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
    
    // TODO: implement germanet and similarity comparison
    private func isSymbolNameRecognized(_ name: String) -> Bool {
        return manager.recognizedWords.contains { $0.lowercased().contains(name.lowercased()) }
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
