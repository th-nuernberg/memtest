//
//  DragDropCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

// Simple View that is used to make patients who are not familiar to the drag n drop concept familiar to it
struct DragDropCalibrationView: View {
    var onNextView: (() -> Void)?
    
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
                    self.onNextView?()
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
            }
        }
        
    }
}


#Preview {
    DragDropCalibrationView()
}
