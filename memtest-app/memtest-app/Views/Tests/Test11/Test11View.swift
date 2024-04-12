//
//  Test10View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 04.04.24.
//

import SwiftUI

struct Test11View: View {
    
    @State private var finished = false
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,
                     indexOfCircle: 10,
                     textOfCircle:"11",destination: {TestEndView()}, content: {
            VStack{
                AudioIndicatorView()
                GeometryReader { geometry in
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            Image("Test10Assets/Cookie_Theft_Picture")
                                .resizable()
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }.onAppear(perform: {
                do {
                    try AudioService.shared.startRecording(to: "test11")
                    print("Recording started")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: 10) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
            }
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 11")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack{
                Text("Ihre zehnte Aufgabe besteht darin, ein Bild")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("und das was Sie dort sehen zu beschreiben.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Beschreiben Sie zum Beispiel was Personen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("in Ihrem Bild machen oder welche Objekte Sie")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("sehen und erkennen können.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,120)
        }, completedContent: { onContinue in
            CompletedView(completedTasks: 10, onContinue: onContinue)
        })
    }
}

#Preview {
    Test11View()
}
