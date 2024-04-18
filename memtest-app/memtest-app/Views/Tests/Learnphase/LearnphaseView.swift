//
//  LearnphaseView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 23.03.24.
//

import SwiftUI

struct LearnphaseView: View {
    
    @State private var finished = false
    
    private var symbolList = TestSymbolList()
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 2,
                     textOfCircle:"L", destination: {Test3View()}, content: {

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
            .onTimerComplete(duration: 60) {
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
                Text("In der Lernphase geht es nicht um eine Aufgabe")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("die Sie bearbeiten sollen, sondern um")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("eine kurze Phase in der wir Ihnen Bilder zeigen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("sie Sie sich für eine spätere Aufgaben so gut wie möglich")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("merken sollen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,200)
        }, completedContent: { onContinue in
            // hacky xD
            Color.clear.onAppear(perform: onContinue)
        })
    }
}

#Preview {
    LearnphaseView()
}
