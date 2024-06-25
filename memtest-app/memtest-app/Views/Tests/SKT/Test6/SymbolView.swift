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

/// `SymbolView` presents a visual grid of the symbols used in the SKT6 Test
/// It utilizes a `GeometryReader` to dynamically calculate and adjust the layout based on the device's screen size.
///
/// - Properties:
///   - `viewModel`: An instance of `SymbolViewModel` which manages the state and interactions for the symbols displayed.
struct SymbolView: View {
    @StateObject var viewModel: SymbolViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let rect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
            ZStack {
                ForEach(Array(zip(viewModel.symbolField.indices, viewModel.symbolField)), id: \.0) { index, symbol in
                    Text(symbol)
                        .font(.system(size: 50.0))
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
    
    /// Calculates the position for each symbol in the grid.
    /// - Parameters:
    ///   - index: The index of the symbol in the grid.
    ///   - rect: The rectangle defining the layout bounds.
    /// - Returns: A CGPoint representing the symbol's position in the view.
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

/// `SymbolViewModel` is responsible for managing the state and logic of symbol interaction within the `SymbolView`.
/// It tracks the number of taps on each symbol and maintains a dynamic field of symbols.
class SymbolViewModel: ObservableObject {
    @Published var symbolCounts: [String: Int] = ["★": 0, "✻": 0, "▢": 0]
    @Published var selectedSymbol: String?
    @Published var symbolField: [String] = []
    @Published var taps: [(Int, String)] = []
    
    func registerTap(on symbolId: Int, symbolType: String) {
        taps.append((symbolId, symbolType))
    }
    
    /// Generates a random field of symbols based on specified parameters.
    /// - Parameters:
    ///   - numberOfSymbols: The total number of symbols to generate.
    ///   - symbols: An array of symbol types to choose from.
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
    Test6View(currentView: .constant(.skt6))
}
