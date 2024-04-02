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
            ZStack {
                ForEach(0..<symbolPositions.count, id: \.self) { index in
                    let symbolPosition = symbolPositions[index]
                    Text(symbolPosition.symbol)
                        .font(.title)
                        .position(symbolPosition.position)
                }
            }
        .onAppear {
            viewModel.initializeSymbolCounts(numberOfSymbols: numberOfSymbols)
            let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
            generateSymbolsPositions(in: rect) // Hier kein 'using' Parameter mehr
            viewModel.selectedSymbol = symbols.randomElement()
        }
    }
    
    private func generateSymbolsPositions(in rect: CGRect) {
        // Adjusting insets to account for symbol size and padding, ensuring symbols don't go outside the view
        let adjustedInsetX = (symbolSize + symbolPadding) / 2
        let adjustedInsetY = (symbolSize + symbolPadding) / 2
        let insetRect = rect.insetBy(dx: adjustedInsetX, dy: adjustedInsetY)
        let quadtree = Quadtree<SymbolPosition>(boundary: insetRect, capacity: 1)

        for _ in 0..<numberOfSymbols {
            let symbol = symbols.randomElement()!
            var placed = false
            while !placed {
                // Generating positions within the adjusted inset bounds
                let x = CGFloat.random(in: insetRect.minX...insetRect.maxX)
                let y = CGFloat.random(in: insetRect.minY...insetRect.maxY)
                let position = CGPoint(x: x, y: y)

                let safeZone = CGRect(x: position.x - (symbolSize + symbolPadding) / 2,
                                      y: position.y - (symbolSize + symbolPadding) / 2,
                                      width: symbolSize + symbolPadding,
                                      height: symbolSize + symbolPadding)

                if !quadtree.query(in: safeZone) {
                    let symbolPosition = SymbolPosition(symbol: symbol, position: position)
                    placed = quadtree.insert(point: position, value: symbolPosition)
                }
            }
        }

        symbolPositions = extractSymbolPositions(from: quadtree)
    }
    
    private func extractSymbolPositions(from quadtree: Quadtree<SymbolPosition>) -> [SymbolPosition] {
        let collectedPoints = quadtree.collect()
        return collectedPoints.map { $0.value }
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


