//
//  LearnphaseView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 23.03.24.
//

import SwiftUI

struct LearnphaseView: View {
    @Binding var currentView: SKTViewEnum
    
    @State private var finished = false
    
    private var symbolList = TestSymbolList()
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    public init(currentView: Binding<SKTViewEnum>) {
        self._currentView = currentView
    }
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 2,
                     textOfCircle:"L", destination: {Test3View(currentView: .constant(.skt3))}, content: {

            LazyVGrid(columns: columns) {
                ForEach(symbolList.symbols, id: \.name) { symbol in
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                            .frame(width: 200)
                            .cornerRadius(20)
                            .padding(.bottom, 20)
                        
                        Image(symbol.fileUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .offset(x: 5, y: -5)
                    }
                }
            }
            .padding(.vertical)
            .padding(.top, 70)
            .onTimerComplete(duration: 5) {
                print("Timer completed")
                finished = true
            }
        }, explanationContent: {
            HStack {
                Text("Lernphase")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack{
                Text("Ihnen werden die Gegenstände noch einmal ganz kurz gezeigt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Bitte prägen Sie sich die Gegenstände gut ein;")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("später werden Sie nach diesen nochmal gefragt")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,200)
        }, completedContent: { onContinue in
            CompletedView(completedTasks: 3, onContinue: {
                currentView = .skt3
                onContinue()
            })
        })
    }
}

#Preview {
    LearnphaseView(currentView: .constant(.learningphase))
}
