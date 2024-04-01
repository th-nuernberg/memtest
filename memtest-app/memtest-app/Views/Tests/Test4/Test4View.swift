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

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct Test4View: View {
    
    @State private var finished = false
    
    let numberCircles = [
            NumberCircles(number: 10, color: UIColor(hex: "#D10B0B")!),
            NumberCircles(number: 81, color: UIColor(hex: "#44FF57")!),
            NumberCircles(number: 72, color: UIColor(hex: "#32FFE6")!),
            NumberCircles(number: 95, color: UIColor(hex: "#9E70FF")!),
            NumberCircles(number: 84, color: UIColor(hex: "#BCE225")!),
            NumberCircles(number: 73, color: UIColor(hex: "#E78CFE")!),
            NumberCircles(number: 16, color: UIColor(hex: "#F5762F")!),
            NumberCircles(number: 13, color: UIColor(hex: "#4478FF")!),
            NumberCircles(number: 29, color: UIColor(hex: "#AC9725")!),
            NumberCircles(number: 40, color: UIColor(hex: "#2CBA76")!),
            // Add more NumberCircles as needed
        ]
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, destination: {Test5View()}, content: {
            
            OrderNumberSceneContainerView(numberCircles: numberCircles, onPositionsChanged: { positions in
                print(positions)
            })
            /*
            .onTimerComplete(duration: 5) {
                print("Timer completed")
                finished = true
            } */

            
            
        }, explanationContent: {
            HStack {
                HStack {
                    ForEach(0..<3) { index in
                        ZStack {
                            Circle()
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                        }
                        .padding(.trailing, 5)
                    }
                }
                ZStack{
                    Circle()
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                    Text("4")
                        .font(.title)
                        .foregroundColor(.white)
                }
                HStack {
                    ForEach(0..<3) { _ in
                        Circle()
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                            .padding(.leading, 5)
                    }
                }
            }
            
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
