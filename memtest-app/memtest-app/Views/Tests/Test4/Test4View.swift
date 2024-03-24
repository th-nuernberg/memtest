//
//  Test4View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test4View: View {
    var body: some View {
        BaseTestView(destination: Test5View(), content: {
            Text("Das ist die Test4View")
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
        })
    }
}

#Preview {
    Test4View()
}