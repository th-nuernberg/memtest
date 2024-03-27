//
//  SymbolView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.03.24.
//

import SwiftUI

import SwiftUI

struct SymbolView: View {
    private let symbols = ["★", "✻", "▢"]
    private let numberOfSymbols = 117
    private let symbolSize: CGFloat = 30.0
    
    @ObservedObject var viewModel: SymbolViewModel
    
    @State private var symbolPositions: [CGPoint] = []
    

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(symbolPositions.enumerated()), id: \.offset) { index, position in
                    Text(self.symbols[index % self.symbols.count])
                        .font(.title)
                        .position(position)
                }
            }
        }
        .onAppear {
            generateSymbolsPositions(in: UIScreen.main.bounds)
        }
    }
    
    private func generateSymbolsPositions(in rect: CGRect) {
        var positions: [CGPoint] = []
        // Reset the symbol counts
        viewModel.symbolCounts = ["★": 0, "✻": 0, "▢": 0]
        
        // Define a smaller area for symbol generation, e.g., inset the current rect
        let insetRect = rect.insetBy(dx: rect.size.width * 0.05, dy: rect.size.height * 0.25)


        for _ in 0..<numberOfSymbols {
            var potentialPosition: CGPoint
            var positionFound = false
            repeat {
                potentialPosition = CGPoint(
                    x: CGFloat.random(in: insetRect.minX...insetRect.maxX),
                    y: CGFloat.random(in: insetRect.minY...insetRect.maxY)
                )
                let isOverlapping = positions.contains { existingPosition in
                    let distance = sqrt(pow(existingPosition.x - potentialPosition.x, 2) +
                                        pow(existingPosition.y - potentialPosition.y, 2))
                    return distance < symbolSize * 1.5
                }
                positionFound = !isOverlapping
            } while !positionFound
            
            // Add the new position
            positions.append(potentialPosition)
            // Randomly choose a symbol and update its count
            let symbol = symbols.randomElement()!
            viewModel.symbolCounts[symbol, default: 0] += 1
        }

        symbolPositions = positions
    }
}

class SymbolViewModel: ObservableObject {
    @Published var symbolCounts: [String: Int] = ["★": 0, "✻": 0, "▢": 0]
    
}


struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = SymbolViewModel()
        SymbolView(viewModel: viewModel)
    }
}


