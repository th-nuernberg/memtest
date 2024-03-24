//
//  Test3View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test3View: View {
    
    @State private var finished = false
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, destination: {Test4View()}, content: {
            Text("Das ist die Test3View")
                .onTimerComplete(duration: 5) {
                    print("Timer completed")
                    finished = true
                }
        }, explanationContent: {
            HStack {
                HStack {
                    ForEach(0..<3) { index in
                        ZStack {
                            if index == 2 {
                                Circle()
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                Text("3")
                                    .font(.title)
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding(.trailing, 5)
                    }
                }
                
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
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
                
                Text("ihnen gezeigten Zahlen zu lesen und zu bennenen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Zum Beispiel sehen Sie die Zahl 12, dann")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("sagen Sie laut und deutlich zwölf.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Die erkannte Zahl wird dann automatisch als")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("erfolgreich erkannt markiert.")
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
