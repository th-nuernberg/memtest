//
//  Test7View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 12.04.24.
//

import SwiftUI

struct Test8View: View {
    @Binding var currentView: SKTViewEnum
    
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false
    @State private var showExplanation = true
    
    private let testDuration = SettingsService.shared.getTestDuration()

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
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 8,
                     textOfCircle:"8", content: {
            //Text(manager.recognizedWords.last ?? "")
            
            VStack{
                
                BaseHeaderView(
                    showAudioIndicator:true,
                    currentView: $currentView,
                    onBack: {
                        self.currentView = .skt7
                        onComplete()
                    },
                    onNext: {
                        self.currentView = .skt9
                        onComplete()
                    }
                )
                
                //AudioIndicatorView()
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
                    try AudioService.shared.startRecording(to: "test8")
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
            }, circleIndex: 8, circleText: "8", showProgressCircles: true, content: {
                HStack {
                    Text("Aufgabenstellung 8")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                VStack{
                    Text("Jetzt kommen wir noch einmal zu den Gegenständen,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text(" die Sie am Anfang gesehen haben.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("An welche können Sie sich jetzt noch erinnern?")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                    
                    Text("Was war auf dem Bildschirm, den Sie zu Beginn gesehen haben?")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                    
                }
                .padding(.top,120)
            })
            
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 8, onContinue: {
                currentView = .skt9
                onContinue()
            })
        })
    }
    
    // TODO: implement germanet and similarity comparison
    private func isSymbolNameRecognized(_ name: String) -> Bool {
        return manager.recognizedWords.contains { $0.lowercased().contains(name.lowercased()) }
    }
    
    private func onComplete() {
        let rememberedSymbolNames = Array(Set(manager.recognizedWords.filter { symbolList.contains(word: $0) }))
        DataService.shared.saveSKT8Results(rememberedSymbolNames: rememberedSymbolNames)
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    Test8View(currentView: .constant(.skt8))
}
