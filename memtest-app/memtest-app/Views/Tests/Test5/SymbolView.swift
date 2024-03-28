//
//  SymbolView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.03.24.
//

import SwiftUI


struct SymbolPosition {
    let symbol: String
    let position: CGPoint
}

struct SymbolView: View {
    private let symbols = ["★", "✻", "▢"]
    private let numberOfSymbols = 170
    private let symbolSize: CGFloat = 30.0
    
    @ObservedObject var viewModel: SymbolViewModel
    
    @State private var symbolPositions: [SymbolPosition] = []
    

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<symbolPositions.count, id: \.self) { index in
                    let symbolPosition = symbolPositions[index]
                    Text(symbolPosition.symbol)
                        .font(.title)
                        .position(symbolPosition.position)
                }
            }
        }
        .onAppear {
            print("appera")
            viewModel.initializeSymbolCounts(numberOfSymbols: numberOfSymbols)
            generateSymbolsPositions(in: UIScreen.main.bounds)
            viewModel.selectedSymbol = symbols.randomElement()
        }
    }
    
    private func generateSymbolsPositions(in rect: CGRect) {
        var generatedSymbols: [String] = []
        
        for symbol in symbols {
            if let count = viewModel.symbolCounts[symbol] {
                for _ in 0..<count {
                    generatedSymbols.append(symbol)
                }
            }
        }
        
        generatedSymbols.shuffle()
        
        print(generatedSymbols.count)
        var newSymbolPositions: [SymbolPosition] = []
        let insetRect = rect.insetBy(dx: rect.size.width * 0.05, dy: rect.size.height * 0.25)
        
        for symbol in generatedSymbols {
            var potentialPosition: CGPoint
            var positionFound = false
            repeat {
                potentialPosition = CGPoint(
                    x: CGFloat.random(in: insetRect.minX...insetRect.maxX),
                    y: CGFloat.random(in: insetRect.minY...insetRect.maxY)
                )
                let isOverlapping = false
                positionFound = !isOverlapping
            } while !positionFound
            
            newSymbolPositions.append(SymbolPosition(symbol: symbol, position: potentialPosition))
        }
        
        symbolPositions = newSymbolPositions
        print(symbolPositions.count)
    }

}

class SymbolViewModel: ObservableObject {
    @Published var symbolCounts: [String: Int] = ["★": 0, "✻": 0, "▢": 0]
    @Published var selectedSymbol: String?
    
    func initializeSymbolCounts(numberOfSymbols: Int) {
        // Diese Methode initialisiert `symbolCounts` mit zufälligen Werten,
        // die sich zu `numberOfSymbols` summieren.
        let symbols = ["★", "✻", "▢"]
        var total = numberOfSymbols
        
        // Zufällige Verteilung der Zahlen (einfaches Beispiel)
        for symbol in symbols {
            let count = total > 0 ? Int.random(in: 0...total) : 0
            symbolCounts[symbol] = count
            total -= count
        }
        
        // Stellen Sie sicher, dass die gesamte Zahl der Symbole genau numberOfSymbols entspricht
        if total > 0, let firstSymbol = symbols.first {
            symbolCounts[firstSymbol, default: 0] += total
        }
    }
    
    var selectedSymbolCount: Int {
        if let selectedSymbol = selectedSymbol {
            print(symbolCounts)
            return symbolCounts[selectedSymbol] ?? 0
        }
        return 0
    }
    
}


struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = SymbolViewModel()
        SymbolView(viewModel: viewModel)
    }
}


