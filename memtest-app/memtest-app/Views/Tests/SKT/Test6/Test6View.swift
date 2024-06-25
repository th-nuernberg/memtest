//
//  Test6View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI
import Combine

/// `Test6View` serves as the Test 6 of the SKT-Tests
///
/// Features:
/// - Displays a grid of symbols for the user to count
/// - Provides explanation and instructions before starting the test
struct Test6View: View {
    @Binding var currentView: SKTViewEnum
    @StateObject private var viewModel: SymbolViewModel = SymbolViewModel()
    @State private var finished = false
    @State private var showExplanation = true
    
    // variable to capture the user's count of symbols
    @State private var userSymbolCount = ""
    
    public init(currentView: Binding<SKTViewEnum>) {
        self._currentView = currentView
    }
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 6,
                     textOfCircle: "6", content: {
            
            VStack {
                // Header view with audio indicator, back and next buttons
                BaseHeaderView(
                    showAudioIndicator: true,
                    currentView: $currentView,
                    onBack: {
                        // Navigate to the previous test
                        self.currentView = .skt5
                        onComplete()
                    },
                    onNext: {
                        // Navigate to the next test
                        self.currentView = .skt7
                        onComplete()
                    }
                )
                
                VStack (spacing: 0) {
                    Text("Gesucht: \(viewModel.selectedSymbol ?? "")")
                        .font(.custom("SFProText-Bold", size: 40))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    SymbolView(viewModel: viewModel)
                        .padding()
                }
                
                HStack {
                    TextField("Anzahl der Symbole:", text: $userSymbolCount)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .onReceive(Just(userSymbolCount)) { newValue in
                            let filtered = String(newValue.filter { $0.isNumber })
                            if let count = Int(filtered), count > 200 {
                                userSymbolCount = String(filtered.prefix(filtered.count - 1))
                            } else {
                                userSymbolCount = filtered
                            }
                        }
                        .padding(.trailing, 20)
                    
                    Button(action: {
                        AudioService.shared.stopRecording()
                        finished.toggle()
                    }) {
                        Text("OK")
                            .font(.custom("SFProText-SemiBold", size: 25))
                            .foregroundStyle(.white)
                    }
                    .padding(13)
                    .background(.blue)
                    .cornerRadius(10)
                }
                .padding(20)
            }
            .onAppear(perform: {
                do {
                    try AudioService.shared.startRecording(to: "skt6")
                    print("Recording started")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: SettingsService.shared.getTestDuration()) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
            }
            
            
        }, explanationContent: { onContinue in
            // Explanation content
            ExplanationView(onNext: {
                showExplanation.toggle()
            }, circleIndex: 6, circleText: "6", showProgressCircles: true, content: {
                HStack {
                    Text("Aufgabenstellung 6")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack {
                    Text("Sie sehen hier auf dieser Tafel verschiedene Symbole:")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Vierecke, Sterne und Blumen.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Wichtig sind nur die gesuchten Symbole.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Zählen Sie bitte laut und so schnell Sie können")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                    
                    Text("alle gesuchten Symbole, die zu sehen sind.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Bitte zählen Sie die gesuchten Symbole Zeile für Zeile,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("von links nach rechts,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("indem Sie mit dem Zeigefinger auf jedes Symbol deuten.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Sind Sie fertig, drücken Sie auf den OK Knopf.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                }
                .padding(.top, 60)
            })
            
        }, completedContent: { onContinue in
            // Completed Test6
            CompletedView(completedTasks: 6, onContinue: {
                // Navigate to the next test
                currentView = .skt7
                onContinue()
            })
        })
    }
    
    /// Function to handle completion of the test
    ///
    /// Actions:
    /// - mark test as finished
    /// - Filters Test-Results and saves them
    /// - Stops recording
    private func onComplete() {
        DataService.shared.saveSKT6Results(symbolToCount: viewModel.selectedSymbol!, symbolCounts: viewModel.symbolCounts, symbolField: viewModel.symbolField, taps: viewModel.taps, userSymbolCount: Int(self.userSymbolCount)!)
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    Test6View(currentView: .constant(.skt6))
}
