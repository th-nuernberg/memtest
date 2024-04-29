//
//  Test8View.swift
//  memtest-app
//
//  Created by Christopher Witzl - TH on 17.04.24.
//

import SwiftUI

struct Test9View: View {
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false
    @State private var symbols: [TestSymbol]
    @State private var showingFirstSet = true
    private let testDuration = 60

    
    private var symbolList = TestSymbolList()
    
    init() {
       _symbols = State(initialValue: Test9View.initializeSymbols())
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height - 140
            let columns = columns()
            let symbolSize = self.dynamicSymbolSize(forWidth: screenWidth, forHeight: screenHeight, numberOfColumns: columns.count, numberOfSymbols: symbols.count/2)
            let (firstGroup, secondGroup) = splitSymbolsIntoGroups()
            
            BaseTestView(showCompletedView: $finished,indexOfCircle: 9,
                         textOfCircle:"9", destination: {Test10View()}, content: {
            
                //Text(manager.recognizedWords.last ?? "")
                AudioIndicatorView()
                Spacer()
                VStack {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(showingFirstSet ? firstGroup : secondGroup, id: \.name) { symbol in
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
                    try! AudioService.shared.startRecording(to: "test9")
                })
                .onTimerComplete(duration: testDuration) {
                    print("Timer completed")
                    finished = true
                    AudioService.shared.stopRecording()
                }
                
                Spacer()
                
                Button(action: {
                    showingFirstSet.toggle()
                }) {
                    Text("Wechseln")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal,50)
                .background(Color.blue)
                .cornerRadius(10)
                
                Spacer()
                
            }, explanationContent: {
                HStack {
                    Text("Aufgabenstellung 9")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                VStack{
                    Text("Ihre neunte Aufgabe besteht darin, wie")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("bei einem Test davor, die gezeigten Objeke zu erkennen")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("und diese zu bennenen.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Sie können zwischen 2 Seiten auf denen Symbole zu sehen sind")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top,20)
                    
                    Text("wechseln. Benennen Sie die Bilder die Sie sich merken konnten")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                }
                .padding(.top,120)
            }, completedContent: {onContinue in
                CompletedView(completedTasks: 9, onContinue: onContinue)
            })
        }
    }
    
    private func columns() -> [GridItem] {
        Array(repeating: .init(.flexible(), spacing: 0), count: 6)
    }

    private func dynamicSymbolSize(forWidth width: CGFloat, forHeight height: CGFloat, numberOfColumns: Int, numberOfSymbols: Int) -> CGFloat {
        let totalVerticalSpacing = CGFloat(numberOfSymbols / numberOfColumns) * 10 // Anpassen basierend auf der Anzahl der Zeilen
        let adjustedHeight = height - totalVerticalSpacing // Verfügbare Höhe nach Abzug des vertikalen Abstands
        let symbolHeight = adjustedHeight / CGFloat(numberOfSymbols / numberOfColumns) // Höhe jedes Symbols
        
        let spacing = CGFloat(numberOfColumns - 1) * 10 // Horizontaler Abstand zwischen den Symbolen
        let adjustedWidth = width - spacing // Verfügbare Breite nach Abzug des horizontalen Abstands
        let symbolWidth = adjustedWidth / CGFloat(numberOfColumns) // Breite jedes Symbols
        
        // Nimmt den kleineren Wert, um sicherzustellen, dass die Symbole nicht außerhalb des sichtbaren Bereichs geraten
        return min(symbolWidth, symbolHeight)
    }
    
    private func isSymbolNameRecognized(_ name: String) -> Bool {
        return manager.recognizedWords.contains { $0.lowercased().contains(name.lowercased()) }
    }
    
    // MARK: Static Methods
    private static func initializeSymbols() -> [TestSymbol] {
       var symbols = TestSymbolList().symbols
       for i in 0...35 {
           symbols.append(TestSymbol(name: "Fragezeichen\(i)", synonyms: [], fileUrl: "Test9Icons/test9_1"))
       }
       symbols.shuffle()
       return symbols
    }
    private func splitSymbolsIntoGroups() -> ([TestSymbol], [TestSymbol]) {
        let midIndex = symbols.count / 2
        let firstGroup = Array(symbols[..<midIndex])
        let secondGroup = Array(symbols[midIndex...])
        return (firstGroup, secondGroup)
    }
}

#Preview {
    Test9View()
}
