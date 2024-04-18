//
//  Test3View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test3View: View {
    
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
                     textOfCircle:"3", destination: {Test4View()}, content: {
            AudioIndicatorView()
            Spacer()
            OrderNumberSceneContainerView(numberCircles: numberCircles, onPositionsChanged: { positions in
                print(positions)
            }, isDragEnabled: false)
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
            }
            .onAppear(perform: {
                try! AudioService.shared.startRecording(to: "test3")
            })
            
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 3")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre dritte Aufgabe besteht darin, die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Ihnen gezeigten Zahlen zu lesen und zu bennenen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Zum Beispiel sehen Sie die Zahl 12, dann")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("sagen Sie laut und deutlich zwölf.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 3, onContinue: onContinue)
        })
    }
}

#Preview {
    Test3View()
}
