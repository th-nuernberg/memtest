//
//  Test2View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

/// `Test2View` serves as the Test 2 of the SKT-Tests
///
/// Features:
/// - Records spoken words the user says to determine if they can recall symbols
/// - Provides explanation and instructions before starting the test
/// - Manages the transition between different views/states within the test
struct Test2View: View {
    @Binding var currentView: SKTViewEnum
    
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    
    @State private var isRecording = false
    
    @State private var finished = false
    
    @State private var showExplanation = true
    
    private let testDuration = SettingsService.shared.getTestDuration()
    
    // List of symbols to be displayed in the test
    private var symbolList = TestSymbolList()
    
    // Layout for the grid of symbols
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
                // Header view with audio indicator, back and next buttons
                BaseHeaderView(
                    showAudioIndicator: true,
                    currentView: $currentView,
                    onBack: {
                        // Navigate to the previous test
                        self.currentView = .skt1
                        onComplete()
                    },
                    onNext: {
                        // Navigate to the next test
                        self.currentView = .learningphase
                        onComplete()
                    }
                )
                
                Spacer()
                
                HStack {
                    Spacer()
                    // Animation gets triggered by the notification (speaking of user) of the SpeechRecognitionManager
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
                // Complete the test when the timer ends
                onComplete()
            }
        }, explanationContent: { onContinue in
            // Explanation content
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
            // Completed Test2
            CompletedView(completedTasks: 2, onContinue: {
                // Navigate to the next test
                currentView = .learningphase
                onContinue()
            })
        })
    }
    
    /// Function to start the recording and resetting recognized words from earlier test
    ///
    /// if not reseting recognized words from last test, symbols will already be selected as recognized ones at the start of the test
    private func startTest() {
        manager.recognizedWords = []
        try? AudioService.shared.startRecording(to: "skt")
    }
    
    /// Function to handle completion of the test
    ///
    /// Actions:
    /// - mark test as finished
    /// - Filters Test-Results and saves them
    /// - Stops recording
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
