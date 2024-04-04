//
//  TestEndView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct TestEndView: View {
    @State var showNextView: Bool = false
    var body: some View {
        VStack{
            Text("Vielen Dank für Ihre Mitarbeit!")
                .font(.custom("SFProText-SemiBold", size: 40))
                .foregroundStyle(Color(hex: "#5377A1"))

            Text("Sie haben alleAufgaben erfolgreich bearbeitet.")
                .font(.custom("SFProText-SemiBold", size: 40))
                .foregroundStyle(Color(hex: "#5377A1"))
                .padding(.top,20)
            
            Text("Ihre Antworten werden jetzt verarbeitet.")
                .font(.custom("SFProText-SemiBold", size: 40))
                .foregroundStyle(Color(hex: "#5377A1"))
                
            
            Text("Bitte geben Sie das Gerät zurück an den Prüfer.")
                .font(.custom("SFProText-SemiBold", size: 40))
                .foregroundStyle(Color(hex: "#5377A1"))
                .padding(.top,20)
            
        }
        .padding(.top,200)
        NavigationStack {
            VStack{
                Button(action: {
                    showNextView.toggle()
                    
                }) {
                    Text("Test beenden")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(10)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom,100)
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $showNextView) {
                    FeedbackView()
                }
            }
        }
    }
}

#Preview {
    TestEndView()
}
