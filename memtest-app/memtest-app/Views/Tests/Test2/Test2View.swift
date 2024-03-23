//
//  Test2View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test2View: View {
    var body: some View {
        BaseTestView(destination: LearnphaseView(), content: {
            Text("Das ist die Test2View")
        }, explanationContent: {
            HStack {
                HStack {
                    ForEach(0..<3) { index in
                        ZStack {
                            if index == 1 {
                                Circle()
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                Text("2")
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
                Text("Aufgabenstellung 2")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre zweite Aufgabe besteht darin, die Bilder die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("ihnen gerade gezeigt wurden, noch einmal")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("noch einmal zu bennen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Zum Beispiel haben wir ihnen vorhin ein Bild")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("Baums gezeigt, dann sagen Sie jetzt Baum.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Das erkannte Objekte wird dann automatisch angezeigt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        })
    }
}

#Preview {
    Test2View()
}
