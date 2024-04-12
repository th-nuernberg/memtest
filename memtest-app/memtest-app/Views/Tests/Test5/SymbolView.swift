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
    private let numberOfSymbols = 117
    private let symbolSize: CGFloat = 30.0
    private let symbolPadding: CGFloat = 20

    
    @ObservedObject var viewModel: SymbolViewModel
    
    @State private var symbolPositions: [SymbolPosition] = []
    

    var body: some View {
        GeometryReader { geometry in
            let rect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
            ZStack {
                ForEach(0..<symbolPositions.count, id: \.self) { index in
                    let symbolPosition = symbolPositions[index]
                    Text(symbolPosition.symbol)
                        .font(.system(size: symbolSize))
                        .position(symbolPosition.position)
                }
            }
            .onAppear {
                generateSymbolsPositions(in: rect)
                viewModel.initializeSymbolCounts(numberOfSymbols: numberOfSymbols)
                viewModel.selectedSymbol = symbols.randomElement()
            }
        }
    }
    
    private func generateSymbolsPositions(in rect: CGRect) {
        let columnWidth = rect.width / CGFloat(17) // Breite einer Spalte
        let rowHeight = rect.height / CGFloat(7) // Höhe einer Reihe

        var positions: [SymbolPosition] = []

        for row in 0..<7 {
            for column in 0..<17 {
                let x = CGFloat(column) * columnWidth + columnWidth / 2 // Zentrum der Spalte
                let y = CGFloat(row) * rowHeight + rowHeight / 2 // Zentrum der Reihe
                let symbol = symbols.randomElement()! // Zufälliges Symbol
                let position = CGPoint(x: x, y: y)
                positions.append(SymbolPosition(symbol: symbol, position: position))
            }
        }
        symbolPositions = positions
    }

}

class SymbolViewModel: ObservableObject {
    @Published var symbolCounts: [String: Int] = ["★": 0, "✻": 0, "▢": 0]
    @Published var selectedSymbol: String?
    
    func initializeSymbolCounts(numberOfSymbols: Int) {
        let symbols = ["★", "✻", "▢"]
        var total = numberOfSymbols
        
        for symbol in symbols {
            let count = total > 0 ? Int.random(in: 0...total) : 0
            symbolCounts[symbol] = count
            total -= count
        }
        if total > 0, let firstSymbol = symbols.first {
            symbolCounts[firstSymbol, default: 0] += total
        }
    }
    
    var selectedSymbolCount: Int {
        if let selectedSymbol = selectedSymbol {
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


