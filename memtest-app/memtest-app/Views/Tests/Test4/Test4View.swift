//
//  Test4View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct NumberCircles {
    var number: Int
    var color: UIColor
}

struct Test4View: View {
    
    @State private var finished = false
    
    let numberCircles = [
            NumberCircles(number: 10, color: UIColor(Color(hex: "#D10B0B"))),
            NumberCircles(number: 81, color: UIColor(Color(hex: "#44FF57"))),
            NumberCircles(number: 72, color: UIColor(Color(hex: "#32FFE6"))),
            NumberCircles(number: 95, color: UIColor(Color(hex: "#9E70FF"))),
            NumberCircles(number: 84, color: UIColor(Color(hex: "#BCE225"))),
            NumberCircles(number: 73, color: UIColor(Color(hex: "#E78CFE"))),
            NumberCircles(number: 16, color: UIColor(Color(hex: "#F5762F"))),
            NumberCircles(number: 13, color: UIColor(Color(hex: "#4478FF"))),
            NumberCircles(number: 29, color: UIColor(Color(hex: "#AC9725"))),
            NumberCircles(number: 40, color: UIColor(Color(hex: "#2CBA76"))),
        ]
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 3,
                     textOfCircle:"4", destination: {Test5View()}, content: {
            
            OrderNumberSceneContainerView(numberCircles: numberCircles, onPositionsChanged: { positions in
                print(positions)
            })
            .onTimerComplete(duration: 10) {
                print("Timer completed")
                finished = true
            }
                        
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 4")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre vierte Aufgabe besteht darin, die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("angezeigten Zahlen zu ordnen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sie ziehen dabei mit ihrem Finger die Zahl")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("die sie ordnen wollen an die Stelle, an die nach")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("die Zahl hingehört hin. Wenn Sie eine Zahl zwischen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("zwei Zahlen ziehen, wird die linke Zahl links davon gesetzt")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("und die rechte Zahl rechts davon.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 4, onContinue: onContinue)
        })
    }
}

#Preview {
    Test4View()
}
