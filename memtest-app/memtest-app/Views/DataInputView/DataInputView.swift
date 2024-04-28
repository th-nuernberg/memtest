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
                SecondDataInputView(patientData: patientData){
                    // TODO: use DataService to save metadata
                    showNextView.toggle()
                }
            }
            
            if showSecondView {
                Button(action: {
                }) {
                    
                }
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $showNextView) {
                    DragDropCalibrationView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DataInputView()
}
