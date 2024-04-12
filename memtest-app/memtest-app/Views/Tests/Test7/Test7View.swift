//
//  Test7View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 12.04.24.
//

import SwiftUI

struct Test7View: View {
    @State private var finished = false
    
    var body: some View {
        
        BaseTestView(showCompletedView: $finished, indexOfCircle: 6, textOfCircle: "7", destination: { Test8View()}, content: {
            Text("daükop")
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 7")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack{
                Text("Ihre siebte Aufgabe besteht darin, die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("für jedes A, B zu sprechen und für jedes B, A.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Die Bichstaben sollen nach einander vorgelesen werden.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,120)
        },
        completedContent: { onContinue in
            
            CompletedView( completedTasks: 7, onContinue: onContinue)
            
        })
        
    }
}

#Preview {
    Test7View()
}
