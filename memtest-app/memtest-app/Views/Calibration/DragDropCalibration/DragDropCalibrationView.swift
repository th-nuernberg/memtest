//
//  DragDropCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

/// `DragDropCalibrationView` is used to familiarize patients with the drag and drop concept
///
/// Features:
/// - Displays instructions for the drag and drop exercise
/// - Contains a drag and drop example scene for practice
/// - Proceeds to the next view upon completion
///
/// - Parameters:
///   - onNextView: A closure to be executed when navigating to the next view
struct DragDropCalibrationView: View {
    var onNextView: (() -> Void)?
    @State var calibrationComplete = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
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
