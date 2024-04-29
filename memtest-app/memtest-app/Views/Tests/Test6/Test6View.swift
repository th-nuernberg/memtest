//
//  Test6View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test6View: View {
    @State private var finished = false
    
    var body: some View {
        
        BaseTestView(showCompletedView: $finished, indexOfCircle: 6, textOfCircle: "6", destination: { Test8View()}, content: {
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
                try! AudioService.shared.startRecording(to: "test6");
            })
            .onTimerComplete(duration: 60, onComplete: {
                finished = true
                AudioService.shared.stopRecording()
            })
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 6")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack{
                Text("Die sechste Aufgabe besteht darin,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("für jedes A, B zu sprechen und für jedes B, A.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Die Buchstaben sollen nacheinander vorgelesen werden.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,120)
        },
        completedContent: { onContinue in
            
            CompletedView( completedTasks: 6, onContinue: onContinue)
            
        })
        
    }
}



#Preview {
    Test6View()
}
