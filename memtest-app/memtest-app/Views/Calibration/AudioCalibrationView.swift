//
//  AudioCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

// Used for getting additional audio data
struct AudioCalibrationView: View {
    var onNextView: (() -> Void)?
    
    @State var testStarted: Bool = false
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
                            .padding(.bottom,100)
                        
                        Text("Einst stritten sich Nordwind und Sonne, wer von ihnen beiden wohl der Stärkere wäre, als ein Wanderer, der in einen warmen Mantel gehüllt war, des Weges daherkam. Sie wurden einig, dass derjenige für den Stärkeren gelten sollte, der den Wanderer zwingen würde, seinen Mantel abzunehmen. ")
                            .font(.custom("SFProText-SemiBold", size: 35))
                            .foregroundStyle(Color(hex: "#5377A1"))
                            .padding(.horizontal,40)
                    }
                    .padding(.all)
                }
                
                Spacer()
                
                Button(action: {
                    
                    if (testStarted) {
                        AudioService.shared.stopRecording()
                        self.onNextView?()
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
                    Text(testStarted ? "Weiter ➔" : "Sprachaufnahme testen")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(.white)
                }
                .padding(20)
                .background(.blue)
                .cornerRadius(10)
                .padding()
                .padding(.leading)
            }
        }
    }
}

#Preview {
    AudioCalibrationView()
}
