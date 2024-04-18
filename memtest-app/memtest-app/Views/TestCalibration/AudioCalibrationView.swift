//
//  AudioCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct AudioCalibrationView: View {
    @State var showNextView: Bool = false
    @State var testStarted: Bool = false
    @ObservedObject var speechRecognitionManager: SpeechRecognitionManager = SpeechRecognitionManager.shared
    var body: some View {
        NavigationStack {
            VStack{
                AudioIndicatorView()
                
                Spacer()
                
                if !testStarted {
                    VStack {
                        Text("Während des Tests wird Ihre Stimme")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        Text("aufgenommen. Oben in der Mitte sehen Sie die ")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        Text("Lautstärke in Grün. Sprechen Sie bitte stets laut")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        Text("und deutlich. Falls Sie zu leise sprechen,")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                        Text("bewegt sich der Lautsprecherpegel nicht.")
                            .font(.custom("SFProText-SemiBold", size: 40))
                            .foregroundStyle(Color(hex: "#5377A1"))
                    }
                } else {
                    VStack {
                        Text("Nordwind und Sonne")
                            .font(.custom("SFProText-SemiBold", size: 60))
                            .foregroundStyle(Color(hex: "#5377A1"))
                            .padding(.bottom)
                        
                        Text("Einst stritten sich Nordwind und Sonne, wer von ihnen beiden wohl der Stärkere wäre, als ein Wanderer, der in einen warmen Mantel gehüllt war, des Weges daherkam. Sie wurden einig, dass derjenige für den Stärkeren gelten sollte, der den Wanderer zwingen würde, seinen Mantel abzunehmen. Der Nordwind blies mit aller Macht, aber je mehr er blies, desto fester hüllte sich der Wanderer in seinen Mantel ein. Endlich gab der Nordwind den Kampf auf. Nun erwärmte die Sonne die Luft mit ihren freundlichen Strahlen, und schon nach wenigen Augenblicken zog der Wanderer seinen Mantel aus. Da musste der Nordwind zugeben, dass die Sonne von ihnen beiden der Stärkere war.")
                            .font(.custom("SFProText-SemiBold", size: 35))
                            .foregroundStyle(Color(hex: "#5377A1"))
                    }
                    .padding(.all)
                }
                
                Spacer()
                
                Button(action: {
                    
                    if (testStarted) {
                        AudioService.shared.stopRecording()
                        showNextView.toggle()
                    } else {
                        
                        do {
                            try AudioService.shared.startRecording(to: "calibration")
                            print("Recording started")
                        } catch {
                            print("Failed to start recording: \(error)")
                        }
                        
                        testStarted.toggle()
                    }
                    
                }) {
                    Text(testStarted ? "Weiter >" : "Sprachaufnahme testen >")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(.white)
                }
                .padding(20)
                .background(.blue)
                .cornerRadius(10)
                .padding()
                .padding(.leading)
                .navigationDestination(isPresented: $showNextView) {
                    Test1View()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    AudioCalibrationView()
}
