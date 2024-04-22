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
                        .position(self.positionForSymbol(index: index, rect: rect))
                        .onTapGesture {
                            viewModel.registerTap(on: index, symbolType: symbol)
                        }
                }
            }
            .onAppear {
                viewModel.generateSymbolField(numberOfSymbols: 125, symbols: ["★", "✻", "▢"])
            }
        }
    }

    private func positionForSymbol(index: Int, rect: CGRect) -> CGPoint {
        let rows = 7
        let firstRowColumns = 17
        let otherRowsColumns = 18
        let isFirstRow = index < firstRowColumns
        let columns = isFirstRow ? firstRowColumns : otherRowsColumns

        let rowHeight = rect.height / CGFloat(rows)
        let columnWidth = isFirstRow ? rect.width / CGFloat(firstRowColumns) : rect.width / CGFloat(otherRowsColumns)

        let rowIndex = isFirstRow ? 0 : (index - firstRowColumns) / otherRowsColumns + 1
        let columnIndex = isFirstRow ? index : (index - firstRowColumns) % otherRowsColumns

        let x = CGFloat(columnIndex) * columnWidth + columnWidth / 2
        let y = CGFloat(rowIndex) * rowHeight + rowHeight / 2
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
    
    func generateSymbolField(numberOfSymbols: Int, symbols: [String]) {
        symbolField = (0..<numberOfSymbols).map { _ in symbols.randomElement()! }
        selectedSymbol = symbolField[0]

        symbolCounts = symbols.reduce(into: [String: Int]()) { counts, symbol in counts[symbol] = 0 }

        for symbol in symbolField {
            symbolCounts[symbol, default: 0] += 1
        }
        print(symbolCounts)
    }

}




#Preview {
    Test5View()
}
