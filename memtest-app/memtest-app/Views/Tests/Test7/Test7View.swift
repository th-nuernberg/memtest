//
//  Test6View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test7View: View {
    @State private var finished = false
    
    var body: some View {
        
        BaseTestView(showCompletedView: $finished, indexOfCircle: 7, textOfCircle: "7", destination: { Test8View()}, content: {
            VStack {
                AudioIndicatorView()
                Spacer()
                
                VStack {
                    Text("ABBABA")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(.black)
                        .padding(.bottom, 20)
                        .underline()
                    Text("A B A A B A B B A A B A B A B B A")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(.black)
                    Text("A A B A B A B B B A B A A B A B A")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
            }
            .onAppear(perform: {
                try! AudioService.shared.startRecording(to: "test7");
            })
            .onTimerComplete(duration: 60, onComplete: {
                finished = true
                AudioService.shared.stopRecording()
            })
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 7")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack{
                Text("Sie sehen hier zwei Zeilen mit den Buchstaben A und B,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            
                Text("darüber eine unterstrichene Übungszeile.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sie sollen jetzt für jedes A, das Sie sehen, „B“ sagen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 20)
                
                Text("und umgekehrt für jedes B,„A“.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Also immer genau den anderen,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 20)
                
                Text("„verkehrten“ Buchstaben laut sagen.")
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
