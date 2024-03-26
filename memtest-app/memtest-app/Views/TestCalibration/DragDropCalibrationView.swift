//
//  DragDropCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct DragDropCalibrationView: View {
    @State var showNextView: Bool = false
    @State var offset = CGSize.zero
    @State var calibrationComplete = false
    @State var finalPosition = CGSize.zero
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12){
                Text("Probieren sie es selbst aus")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top,10)
                    .padding(.horizontal)
                Text("Sie müssen den Kreis in das Ziel bewegen um fortfahren zu können.")
                Spacer()
            }
            HStack{
                Spacer()
                    .frame(width:100)
                //Movable
                Circle()
                    .foregroundColor(.blue.opacity(0.8))
                    .frame(width: 150, height: 150)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                self.offset = CGSize(width: gesture.translation.width + self.finalPosition.width, height: gesture.translation.height + self.finalPosition.height)
                                checkOverlap()
                            }
                            .onEnded{ gesture in
                                self.finalPosition = self.offset
                            }
                    )
                Spacer()
                //Unmovable
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.red.opacity(0.8))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("Ziel")
                            .foregroundColor(.black)
                    )
                    .padding()
                Spacer()
                    .frame(width: 100)
            }
            VStack{
                Spacer()
                Text("Das ist die DragDropCalibrationView")
                Button{
                    if(calibrationComplete){
                        showNextView.toggle()
                    }
                }label: {
                    Text("Zur nächsten View")
                }
                .navigationDestination(isPresented: $showNextView) {
                    TipCalibrationView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    func checkOverlap(){
        let tolerance: CGFloat = 300
        let xDiff = abs(finalPosition.width)
        let yDiff = abs(finalPosition.height)
        calibrationComplete = xDiff <= tolerance && yDiff <= tolerance
    }
}

#Preview {
    DragDropCalibrationView()
}
