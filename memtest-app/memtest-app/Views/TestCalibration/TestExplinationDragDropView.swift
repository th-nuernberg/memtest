//
//  TestExplinationDragDropView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct TestExplinationDragDropView: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                
                Spacer()
                
                VStack {
                    Text("Während des Tests wird es Aufgaben geben")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text("bei denen sie Objekte mit dem Finger")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text("verschieben müssen.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text(" ")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text("Sie können die Objekte verschieben, indem sie")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text("mit dem Finger auf das Objekt klicken und halten")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text("und es dann zu dem Ort ziehen wo sie es haben wollen.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text(" ")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    Text("Drücken sie die blaue taste um das auszuprobieren.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))

                }
                
                Spacer()
                
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
                    DragDropCalibrationView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    TestExplinationDragDropView()
}
