//
//  LearnphaseView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 23.03.24.
//

import SwiftUI

/// `LearnphaseView` serves as the learning phase of the SKT-Tests
///
/// Features:
/// - Displays a list of symbols for the user to memorize
/// - Provides explanation and instructions before starting the learning phase
struct LearnphaseView: View {
    @Binding var currentView: SKTViewEnum
    @State private var finished = false
    @State private var showExplanation = true
    
    // List of symbols to be displayed in the learning phase
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
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 2,
                     textOfCircle:"L", content: {
            
            // Header view with audio indicator, back and next buttons
            BaseHeaderView(
                showAudioIndicator: true,
                currentView: $currentView,
                onBack: {
                    // Navigate to the previous test
                    self.currentView = .skt2
                },
                onNext: {
                    // Navigate to the next test
                    self.currentView = .skt3
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
            .onTimerComplete(duration: 5) {
                print("Timer completed")
                // Complete the learning phase when the timer ends
                finished = true
            }
        }, explanationContent: { onContinue in
            // Explanation content
            ExplanationView(onNext: {
                showExplanation.toggle()
            }, circleIndex: 2, circleText: "L", showProgressCircles: true, content: {
                HStack {
                    Text("Lernphase")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack {
                    Text("Ihnen werden die Gegenstände noch einmal ganz kurz gezeigt.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Bitte prägen Sie sich die Gegenstände gut ein;")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("später werden Sie nach diesen nochmal gefragt")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                }
                .padding(.top, 200)
            })
            
        }, completedContent: { onContinue in
            // Completed learningphase
            CompletedView(completedTasks: 3, onContinue: {
                // Navigate to the next test
                currentView = .skt3
                onContinue()
            })
        })
    }
}

#Preview {
    LearnphaseView(currentView: .constant(.learningphase))
}
