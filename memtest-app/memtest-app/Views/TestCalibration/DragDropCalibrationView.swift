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
                Spacer()
            }
            HStack{
                Spacer()
                //Movable
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.blue)
                    .frame(width: 100, height: 100)
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
                    .foregroundColor(.red)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("Ziel")
                            .foregroundColor(.black)
                    )
                    .padding()
                Spacer()
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
