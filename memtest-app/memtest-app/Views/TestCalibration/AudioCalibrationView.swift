//
//  AudioCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct AudioCalibrationView: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Text("Das ist die AudioCalibrationView")
                Button{
                    showNextView.toggle()
                }label: {
                    Text("Zur nächsten View")
                }
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
