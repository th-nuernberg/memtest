//
//  DragDropCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct DragDropCalibrationView: View {
    @State var showNextView: Bool = false
    @State var calibrationComplete = false
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 12){
                Spacer()
                Text("Bitte verschieben Sie den Punkt in das leere Rechteck.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                Spacer()
                
                DragDropExampleSceneContainerView(calibrationComplete: $calibrationComplete)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                Button(action: {
                    showNextView.toggle()
                }) {
                    Text("Weiter")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(.white)
                }
                .disabled(!calibrationComplete)
                .padding(20)
                .background(calibrationComplete ? .blue : .gray)
                .cornerRadius(10)
                .padding()
                .padding(.leading)
                .navigationDestination(isPresented: $showNextView) {
                    AudioCalibrationView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
        
    }
}


#Preview {
    DragDropCalibrationView()
}
