//
//  WelcomeStudyView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 21.03.24.
//

import SwiftUI

struct WelcomeStudyView: View {
    
    @State var showNextView: Bool = false
    @State private var studyID = "1234-7896"
    @State private var studyResearchName = "Mustermann University"
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("Willkommen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.bottom,30)
                
                Text("Vielen Dank, das Sie an der Studie " + studyID)
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("von " + studyResearchName + " teilnehmen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Button(action: {
                    showNextView.toggle()
                }) {
                    Text("Gerät überreichen")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(.white)
                }
                .padding(20)
                .background(.blue)
                .cornerRadius(10)
                .padding(.top,70)
                .padding(.leading)
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $showNextView) {
                    DataInputView()
                }
                    
            }
        }
    }
}

#Preview {
    WelcomeStudyView()
}
