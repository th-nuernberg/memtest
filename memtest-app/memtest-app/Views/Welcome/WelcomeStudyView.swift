//
//  WelcomeStudyView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 21.03.24.
//

import SwiftUI

struct WelcomeStudyView: View {
    
    @State var showNextView: Bool = false
    @State private var studyID = ""
    @State private var studyResearchName = "der TH Nürnberg"
    
    var onNextView: ((_ nextView: WelcomeViewEnum) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("Willkommen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.bottom,30)
                
                Text("Vielen Dank, dass Sie an der Studie " + studyID)
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("" + studyResearchName + " teilnehmen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Button(action: {
                    showNextView.toggle()
                    onNextView?(.next)
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
            }
            .onAppear(perform: {
                studyID = DataService.shared.getStudyId()
            })
        }
    }
}

#Preview {
    WelcomeStudyView()
}
