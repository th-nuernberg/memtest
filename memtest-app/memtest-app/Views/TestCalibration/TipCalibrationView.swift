//
//  TipCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct TipCalibrationView: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Text("Das ist die TipCalibrationView")
                Button{
                    showNextView.toggle()
                }label: {
                    Text("Zur nächsten View")
                }
                .navigationDestination(isPresented: $showNextView) {
                    AudioCalibrationView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    TipCalibrationView()
}
