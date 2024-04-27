//
//  DataInputView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI
import Combine

struct DataInputView: View {
    
    @StateObject private var patientData = PatientData()
    @State var showSecondView = false
    @State var showNextView: Bool = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack{
            if !showSecondView {
                FirstDataInputView(patientData: patientData) {
                    self.showSecondView = true
                }
            } else {
                SecondDataInputView(patientData: patientData)
            }
            
            if showSecondView {
                Button(action: {
                    showNextView.toggle()
                }) {
                    Text("Zur Einführung")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(10)
                .background(patientData.age.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(10)
                .padding(.bottom,100)
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $showNextView) {
                    DragDropCalibrationView()
                }
            }
        }
    }
}

#Preview {
    DataInputView()
}
