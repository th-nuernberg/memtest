//
//  Test1View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

/// `Test1View` serves as the Test 1 of the SKT-Tests
///
/// Features:
/// - Displays different Symbols already preselected
/// - The view records spoken words the user says to determine if they correctly name the symbols
/// - Provides explanation and instructions before starting the test
struct Test1View: View {
    @Binding var currentView: SKTViewEnum
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false
    @State private var showExplanation = true
    
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
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 0,
                     textOfCircle: "1", content: {
            
            // Header view with audio indicator, back and next buttons
            BaseHeaderView(
                showAudioIndicator: true,
                currentView: $currentView,
                onBack: {
                    // Navigate to the previous test
                    // Special-Case here cause its the first Test so going back just goes to the same test again
                    self.currentView = .skt1
                    onComplete()
                },
                onNext: {
                    // Navigate to the next test
                    self.currentView = .skt2
                    onComplete()
                }
            )
            
            // Grid of symbols
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
                    }
                }
            }
            .padding(.vertical)
            .onAppear(perform: {
                // Reset previously recognized words and start recording
                manager.recognizedWords = []
                do {
                    try AudioService.shared.startRecording(to: "test1")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: SettingsService.shared.getTestDuration()) {
                // Complete the test when the timer ends
                onComplete()
            }
        }, explanationContent: { onContinue in
            
            // Explanation content
            ExplanationView(onNext: {
                showExplanation = false
            }, circleIndex: 0, circleText: "1", showProgressCircles: true, content: {
                HStack {
                    Text("Aufgabenstellung 1")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                VStack {
                    Text("Es werden Ihnen nun Bilder von Gegenständen gezeigt,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text(" die Sie alle schon einmal gesehen haben,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("die Ihnen also bekannt sind.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Es kommt jetzt darauf an, dass Sie, so schnell Sie können,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                    
                    Text("von links nach rechts sagen,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("wie man die Gegenstände benennt oder wie sie heißen")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("und dass Sie sich die Gegenstände gleichzeitig auch einprägen.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Sie werden nämlich später noch einmal nach diesen gefragt.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                }
                .padding(.top, 40)
                
                Spacer()
            })
        }, completedContent: { onContinue in
            // Completed Test1
            CompletedView(completedTasks: 1, onContinue: {
                // Navigate to the next test
                currentView = .skt2
                onContinue()
            })
        })
    }
    
    /// Function to start or stop recording
    private func startStopRecording() {
        if isRecording {
            AudioService.shared.stopRecording()
        } else {
            do {
                try AudioService.shared.startRecording(to: "skt1")
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
        isRecording.toggle()
    }
    
    /// Function to handle completion of the test
    ///
    /// Actions:
    /// - mark test as finished
    /// - Filters Test-Results and saves them
    /// - Stops recording
    private func onComplete() {
        let recognizedSymbols = Array(Set(manager.recognizedWords.filter { symbolList.contains(word: $0) }))
        DataService.shared.saveSKT1Results(recognizedSymbolNames: recognizedSymbols)
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    Test1View(currentView: .constant(.skt1))
}
