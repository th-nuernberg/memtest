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
                    Text("und deutlich. Wenn Sie zu leise sprechen,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text("bewegt sich der Lautsprecherpegel nicht.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
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
