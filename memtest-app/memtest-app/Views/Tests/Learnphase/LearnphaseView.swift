//
//  LearnphaseView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 23.03.24.
//

import SwiftUI

struct LearnphaseView: View {
    var body: some View {
        BaseTestView(destination: Test3View(), content: {
            Text("Das ist die LearnphaseView")
        }, explanationContent: {
            HStack {
                Text("Lernphase")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack{
                Text("In der Lernphase geht es nicht um eine Aufgabe")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("die Sie bearbeiten sollen, sondern um")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("eine kurze Phase in der wir Ihnen Bilder zeigen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("sie Sie sich für eine spätere Aufgaben so gut wie möglich")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("merken sollen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,200)
        })
    }
}

#Preview {
    LearnphaseView()
}
