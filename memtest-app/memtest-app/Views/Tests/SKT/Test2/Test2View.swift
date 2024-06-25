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
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 1,
                     textOfCircle:"2", content: {
            VStack {
                BaseHeaderView(
                    showAudioIndicator: true,
                    currentView: $currentView,
                    onBack: {
                        self.currentView = .skt1
                        onComplete()
                    },
                    onNext: {
                        self.currentView = .learningphase
                        onComplete()
                    }
                )
                
                Spacer()
                HStack {
                    Spacer()
                    // Animation gets triggered by the notification of the SpeechRecognitionManager
                    AvatarView(gifName: "Avatar_Nicken_fast")
                    Spacer()
                    HourglassView(size: 300, lineWidth: 15, duration: testDuration)
                        .padding(.trailing, 150)
                    Spacer()
                }
                Spacer()
            }
            .onAppear(perform: startTest)
            .onTimerComplete(duration: testDuration) {
                onComplete()
            }
        }, explanationContent: { onContinue in
            ExplanationView(onNext: {
                showExplanation.toggle()
            }, circleIndex: 1, circleText: "2", showProgressCircles: true, content: {
                VStack {
                    Text("Aufgabenstellung 2")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    VStack {
                        Text("Sagen Sie bitte jetzt,")
                        Text("welche Gegenstände Sie gerade gesehen haben.")
                        Text("An welche können Sie sich noch erinnern?")
                    }
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 120)
                }
            })
        }, completedContent: { onContinue in
            CompletedView(completedTasks: 2, onContinue: {
                currentView = .learningphase
                onContinue()
            })
        })
    }
    
    private func startTest() {
        manager.recognizedWords = []
        try? AudioService.shared.startRecording(to: "skt")
    }
    
    private func onComplete() {
        let rememberedSymbols = Array(Set(manager.recognizedWords.filter { symbolList.contains(word: $0) }))
        DataService.shared.saveSKT2Results(rememberedSymbolNames: rememberedSymbols)
        AudioService.shared.stopRecording()
        finished = true
    }
}

#Preview {
    Test2View(currentView: .constant(.skt2))
}

