//
//  Test2View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test2View: View {
    @Binding var currentView: SKTViewEnum
    
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false
    @State private var showExplanation = true
    private let testDuration = 60
    
    private var symbolList = TestSymbolList()
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    public init(currentView: Binding<SKTViewEnum>) {
        self._currentView = currentView
    }
    
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 1,
                     textOfCircle:"2", content: {
            
            //Text(manager.recognizedWords.last ?? "")
            
            VStack{
                AudioIndicatorView()
                Spacer()
                HStack {
                    Spacer()
                    AvatarView(gifName: "Avatar_Nicken_fast")
                    Spacer()
                    HourglassView(size: 300, lineWidth: 15, duration: testDuration)
                        .padding(.trailing, 150)
                    
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
        }, explanationContent: {onContinue in
            
            ExplanationView(onNext: {
                showExplanation.toggle()
            },circleIndex: 1, circleText: "2", showProgressCircles: true, content: {
                HStack {
                    Text("Aufgabenstellung 2")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                VStack{
                    Text("Sagen Sie bitte jetzt,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("welche Gegenstände Sie gerade gesehen haben. ")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("An welche können Sie sich noch erinnern?")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                }
                .padding(.top,120)
            })
            
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 2, onContinue:  {
                currentView = .learningphase
                print(currentView)
                onContinue()
            })
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
    Test2View(currentView: .constant(.skt2))
}
