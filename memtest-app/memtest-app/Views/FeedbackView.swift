//
//  FeedbackView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct FeedbackView: View {
    @State var showNextView: Bool = false
    @State var isSelected: Bool = false
    @State var errorDescription: String = ""
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Fehlerreport")
                .font(.system(size: 30))
            Text("Technische Fehler")
                .font(.system(size: 40))
            Text("Bitte informieren Sie uns über technische Fehler bei der Benutzung des Prototyps.")
                .font(.system(size: 25))
            
            Divider()
                
            Text("Möchten Sie einen Fehler melden?")
            HorizontalRadioButtons(isSelected: $isSelected)
            
            if isSelected {
                
                TextEditor(text: $errorDescription)
                            .frame(width: 1000, height: 300)
                            .scrollContentBackground(.hidden)
                            .cornerRadius(20)
                            .background(.white)
                            .overlay(
                                     RoundedRectangle(cornerRadius: 10)
                                       .stroke(Color(hex: "#CAD8E3"), lineWidth: 5)
                                     )
                            .padding()
            }
            
            Button(action: {
                print(errorDescription)
                self.showNextView = true
            }) {
                Text("Weiter")
                    .foregroundColor(.white)
                    .padding()
                    .background(!self.isSelected || !self.errorDescription.isEmpty ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(isSelected && errorDescription.isEmpty)
            .padding(.top, 30)
            
        }
        .padding(.leading, 100)
        
        .padding(.trailing, 70)
        .navigationDestination(isPresented: $showNextView) {
            //TODO: Start Datatransfer to university server
            EmptyView()
        }
        .navigationBarBackButtonHidden(true)
       
    }
}

struct HorizontalRadioButtons: View {
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                self.isSelected = true
            }) {
                HStack {
                    Image(systemName: self.isSelected ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(self.isSelected ? .accentColor : .black)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                    Text("Ja")
                }
            }
            
            Button(action: {
                self.isSelected = false
            }) {
                HStack {
                    Image(systemName: self.isSelected ? "circle" : "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(self.isSelected ? .black : .accentColor)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                    Text("Nein")
                }
            }
        }
    }
}


#Preview {
    FeedbackView()
}


