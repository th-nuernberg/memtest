//
//  TestExplinationTipView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct TestExplinationTipView: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Text("Sie können die Objekte auch bewegen indem sie einmal")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                Text("darauf klicken und dann dorthin klicken wo sie")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                Text("das Objekt hinbewegen wollen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                Text("")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                Text("Um das auszuprobieren tippen sie auf die Blaue Taste.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                Button(action:{
                    showNextView.toggle()
                }){
                    Text("Verschiebefunktion testen")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(.white)
                }
                .padding(20)
                .background(.blue)
                .cornerRadius(10)
                .padding()
                .padding(.leading)
                .navigationDestination(isPresented: $showNextView) {
                    TipCalibrationView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    TestExplinationTipView()
}
