//
//  SymbolView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.03.24.
//

import SwiftUI

struct SymbolPosition: Identifiable {
    let id: Int
    let symbol: String
}


struct SymbolView: View {
    @StateObject var viewModel: SymbolViewModel

    var body: some View {
        GeometryReader { geometry in
            let rect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
            ZStack {
                ForEach(Array(zip(viewModel.symbolField.indices, viewModel.symbolField)), id: \.0) { index, symbol in
                    Text(symbol)
                        .font(.system(size: 30.0))
                        .position(self.positionForSymbol(index: index, rect: rect, columns: 17, rows: 7))
                        .onTapGesture {
                            viewModel.registerTap(on: index, symbolType: symbol)
                        }
                }
            }
            .onAppear {
                viewModel.generateSymbolField(numberOfSymbols: 119, symbols: ["★", "✻", "▢"])
            }
        }
    }

    private func positionForSymbol(index: Int, rect: CGRect, columns: Int, rows: Int) -> CGPoint {
        let columnWidth = rect.width / CGFloat(columns)
        let rowHeight = rect.height / CGFloat(rows)
        let x = CGFloat(index % columns) * columnWidth + columnWidth / 2
        let y = CGFloat(index / columns) * rowHeight + rowHeight / 2
        return CGPoint(x: x, y: y)
    }
}





class SymbolViewModel: ObservableObject {
    @Published var symbolCounts: [String: Int] = ["★": 0, "✻": 0, "▢": 0]
    @Published var selectedSymbol: String?
    @Published var symbolField: [String] = []
    @Published var taps: [(Int, String)] = []

    func registerTap(on symbolId: Int, symbolType: String) {
        taps.append((symbolId, symbolType))
    }

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

    func generateSymbolField(numberOfSymbols: Int, symbols: [String]) {
        symbolField = (0..<numberOfSymbols).map { _ in symbols.randomElement()! }
    }
}




#Preview {
    Test5View()
}
