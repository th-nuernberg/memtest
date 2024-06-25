//
//  Test9View.swift
//  memtest-app
//
//  Created by Christopher Witzl - TH on 17.04.24.
//

import SwiftUI

/// `Test9View` serves as the Test 9 of the SKT-Tests
///
/// Features:
/// - Prompts the user to recall previously shown symbols from a grid
/// - Provides explanation and instructions before starting the test
struct Test9View: View {
    @Binding var currentView: SKTViewEnum
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false
    @State private var showExplanation = true
    // variable to hold the list of symbols to be displayed
    @State private var symbols: [TestSymbol]
    
    // Duration of the test retrieved from settings
    private let testDuration = SettingsService.shared.getTestDuration()
    
    // List of symbols used in the test
    private var symbolList = TestSymbolList()
    
    public init(currentView: Binding<SKTViewEnum>) {
        _symbols = State(initialValue: Test9View.initializeSymbols())
        self._currentView = currentView
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height - 140
            let columns = columns()
            let symbolSize = self.dynamicSymbolSize(forWidth: screenWidth, forHeight: screenHeight, numberOfColumns: columns.count, numberOfSymbols: symbols.count)
            let symbolGroup = Array(symbols)
            
            BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 9,
                         textOfCircle: "9", content: {
                
                BaseHeaderView(
                    showAudioIndicator: true,
                    currentView: $currentView,
                    onBack: {
                        self.currentView = .skt8
                        onComplete()
                    },
                    onNext: {
                        self.currentView = .finished
                        onComplete()
                    }
                )
                
                Spacer()
                VStack {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(symbolGroup, id: \.name) { symbol in
                            ZStack {
                                Rectangle()
                                    .fill(.gray)
                                    .frame(width: symbolSize, height: symbolSize)
                                    .cornerRadius(20)
                                
                                Image(symbol.fileUrl)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: symbolSize * 0.75, height: symbolSize * 0.75)
                                
                            }
                            .padding(.bottom, 10)
                        }
                    }
                }
                .onAppear(perform: {
                    try! AudioService.shared.startRecording(to: "skt9")
                })
                .onTimerComplete(duration: testDuration) {
                    print("Timer completed")
                    finished = true
                    AudioService.shared.stopRecording()
                }
                
                Spacer()
                
            }, explanationContent: { onContinue in
                // Explanation content
                ExplanationView(onNext: {
                    showExplanation.toggle()
                }, circleIndex: 9, circleText: "9", showProgressCircles: true, content: {
                    HStack {
                        Text("Aufgabenstellung 9")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack {
                        Text("Um es Ihnen leichter zu machen,")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        
                        Text("sich an die Gegenstände zu erinnern,")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        
                        Text("sehen Sie gleich viele Gegenstände auf dem Bildschirm.")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        
                        Text("Unter diesen befinden sich auch diejenigen,")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                            .padding(.top, 20)
                        
                        Text("die Sie vorhin gesehen haben.")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        
                        Text("Suchen Sie diese bitte Zeile für Zeile heraus.")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        
                        Text("Deuten Sie bitte mit dem Finger darauf")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                            .padding(.top, 20)
                        
                        Text("und sagen Sie nochmals laut,")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        
                        Text("was auf dem Bild dargestellt ist.")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        
                        Text("Mit dem Knopf können Sie zur nächsten Seite wechseln.")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                            .padding(.top, 20)
                    }
                    .padding(.top, 30)
                })
                
            }, completedContent: { onContinue in
                CompletedView(completedTasks: 9, onContinue: {
                    currentView = .finished
                    onContinue()
                })
            })
        }
    }
    
    /// Configures the grid columns
    private func columns() -> [GridItem] {
        Array(repeating: .init(.flexible(), spacing: 0), count: 6)
    }
    
    /// Calculates the dynamic symbol size based on screen dimensions
    private func dynamicSymbolSize(forWidth width: CGFloat, forHeight height: CGFloat, numberOfColumns: Int, numberOfSymbols: Int) -> CGFloat {
        let totalVerticalSpacing = CGFloat(numberOfSymbols / numberOfColumns) * 10 // Adjust based on number of rows
        let adjustedHeight = height - totalVerticalSpacing // Available height after subtracting vertical spacing
        let symbolHeight = adjustedHeight / CGFloat(numberOfSymbols / numberOfColumns) // Height of each symbol
        
        let spacing = CGFloat(numberOfColumns - 1) * 10 // Horizontal spacing between symbols
        let adjustedWidth = width - spacing // Available width after subtracting horizontal spacing
        let symbolWidth = adjustedWidth / CGFloat(numberOfColumns) // Width of each symbol
        
        // Takes the smaller value to ensure symbols do not exceed visible area
        return min(symbolWidth, symbolHeight)
    }
    
    /// Checks if a recognized word matches any symbol name
    private func isSymbolNameRecognized(_ name: String) -> Bool {
        return manager.recognizedWords.contains { $0.lowercased().contains(name.lowercased()) }
    }
    
    /// Initializes the symbols for the test
    private static func initializeSymbols() -> [TestSymbol] {
        var symbols = TestSymbolList().symbols
        for i in 0...35 {
            symbols.append(TestSymbol(name: "Fragezeichen\(i)", synonyms: [], fileUrl: "Test9Icons/test9_1"))
        }
        symbols.shuffle()
        return symbols
    }
    
    /// Function to handle completion of the test
    ///
    /// Actions:
    /// - mark test as finished
    /// - Filters Test-Results and saves them
    /// - Stops recording
    private func onComplete() {
        let correctlyRememberedSymbolNames = Array(Set(manager.recognizedWords.filter { symbolList.contains(word: $0) }))
        DataService.shared.saveSKT9Results(correctlyRememberedSymbolNames: correctlyRememberedSymbolNames)
        
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    Test9View(currentView: .constant(.skt9))
}
