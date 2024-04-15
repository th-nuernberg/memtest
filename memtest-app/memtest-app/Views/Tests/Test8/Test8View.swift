//
//  Test7View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test8View: View {
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false
    @State private var symbols: [TestSymbol] // Nutzt @State, um die Symbole zu speichern

    
    private var symbolList = TestSymbolList()
    
    init() {
       _symbols = State(initialValue: Test8View.initializeSymbols()) // Initialisiert die Symbole beim ersten Laden
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height - 140 // Abzug für obere und untere UI-Elemente
            let columns = columns()
            let symbolSize = self.dynamicSymbolSize(forWidth: screenWidth, forHeight: screenHeight, numberOfColumns: columns.count, numberOfSymbols: symbols.count)
            
            BaseTestView(showCompletedView: $finished,indexOfCircle: 7,
                         textOfCircle:"8", destination: {Test9View()}, content: {
            
                //Text(manager.recognizedWords.last ?? "")
                LazyVGrid(columns: columns, spacing: 10) { // Fügt etwas Abstand zwischen den Zellen hinzu
                    ForEach(symbols , id: \.name) { symbol in
                        
                        ZStack {
                            Rectangle()
                                .fill(self.isSymbolNameRecognized(symbol.name) ? Color.gray.opacity(0.5) : .gray)
                                .frame(width: symbolSize, height: symbolSize)
                                .cornerRadius(20)
                            
                        
                            Image(symbol.fileUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: symbolSize * 0.75, height: symbolSize * 0.75)
                           
                        }
                        .padding(.bottom, 10) // Fügt etwas Abstand zum unteren Rand hinzu
                    }
                }
                .padding(.vertical)
                .padding(.top, 70)
                .onAppear(perform: {
                    manager.recognizedWords = []
                    do {
                        try AudioService.shared.startRecording(to: "test8")
                    } catch {
                        print("Failed to start recording: \(error)")
                    }
                })
                .onTimerComplete(duration: 10) {
                    print("Timer completed")
                    finished = true
                    AudioService.shared.stopRecording()
                }
                
            }, explanationContent: {
                HStack {
                    Text("Aufgabenstellung 8")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                VStack{
                    Text("Ihre siebte Aufgabe besteht darin, wie")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("bei einem Test davor, die gezeigten Objeke zu erkennen")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("und diese zu bennenen.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Sie sehen zum Beispiel ein Bild eines Baums.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top,20)
                    
                    Text("Dann sagen sie deutlich das Wort Baum und das")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("jewewilige Bild wird als erfolgreich erkannt markiert")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                }
                .padding(.top,120)
            }, completedContent: {onContinue in
                CompletedView(completedTasks: 7, onContinue: onContinue)
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
       for i in 0...23 {
           symbols.append(TestSymbol(name: "Fragezeichen\(i)", synonyms: [], fileUrl: "Test8Icons/test8_1"))
       }
       symbols.shuffle() // Mischen der Symbole nur einmal beim Initialisieren
       return symbols
    }
}

#Preview {
    Test8View()
}
