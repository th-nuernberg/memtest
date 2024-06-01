//
//  Test6View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test7View: View {
    @Binding var currentView: SKTViewEnum
    
    @State private var finished = false
    @State private var showExplanation = true

    public init(currentView: Binding<SKTViewEnum>) {
        self._currentView = currentView
    }
    
    var body: some View {
        
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 7, textOfCircle: "7", content: {
            VStack {
                
                BaseHeaderView(
                    showAudioIndicator:true,
                    currentView: $currentView,
                    onBack: {
                        self.currentView = .skt6
                        onComplete()
                    },
                    onNext: {
                        self.currentView = .skt8
                        onComplete()
                    }
                )
                
                //AudioIndicatorView()
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
            .onTimerComplete(duration: SettingsService.shared.getTestDuration(), onComplete: {
                DataService.shared.saveSKT7Results()
                finished = true
                AudioService.shared.stopRecording()
            })
        }, explanationContent: {onContinue in
            
            ExplanationView(onNext: {
                showExplanation.toggle()
            }, circleIndex: 7, circleText: "7", showProgressCircles: true, content: {
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
            })
            
        },
        completedContent: { onContinue in
            
            CompletedView( completedTasks: 7, onContinue: {
                currentView = .skt8
                onContinue()
            })
            
        })
        
    }
    
    private func onComplete() {
        // TODO: save currentDragElements in json
        finished = true
        AudioService.shared.stopRecording()
    }
    
}



#Preview {
    Test7View(currentView: .constant(.skt7))
}
