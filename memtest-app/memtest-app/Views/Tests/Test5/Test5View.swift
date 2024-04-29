//
//  Test5View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 29.04.24.
//

import SwiftUI

struct Test5View: View {
    @State private var finished = false
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 5,
                     textOfCircle:"5", destination: {Test6View()}, content: {
            
            Text("test5")
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                finished = true
            }
                        
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 5")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre fünfte Aufgabe besteht darin, die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("angezeigten Zahlen auf ihre .")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("ursprüngliche Position zurückzulegen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 5, onContinue: onContinue)
        })
    }
}

#Preview {
    Test5View()
}
