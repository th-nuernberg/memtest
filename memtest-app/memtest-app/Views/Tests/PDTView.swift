//
//  Test10View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 04.04.24.
//

import SwiftUI

struct PDTView: View {
    var onNextView: (() -> Void)?
    
    @State private var finished = false
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,
                     indexOfCircle: 12,
                     textOfCircle:"12", content: {
            VStack{
                AudioIndicatorView()
                GeometryReader { geometry in
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            Image("Test12Assets/Cookie_Theft_Picture")
                                .resizable()
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }.onAppear(perform: {
                do {
                    try AudioService.shared.startRecording(to: "test12")
                    print("Recording started")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
            }
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 12")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack{
                Text("Ihnen wird gleich ein Bild gezeigt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Bitte beschreiben Sie was auf diesem zu sehen ist.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 20)
            }
            .padding(.top,120)
        }, completedContent: { onContinue in
            CompletedView(completedTasks: 12, onContinue: {
                onNextView?()
                onContinue()
            })
        })
    }
}

#Preview {
    PDTView()
}
