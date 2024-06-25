//
//  DataInputView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI
import Combine

/// `DataInputView` handles the input of patient data
///
/// Features:
/// - User can enter patient data
/// - Navigates to the next view upon completion of data entry
struct DataInputView: View {
    var dataService: DataService = DataService.shared
    @StateObject private var patientData = PatientData()
    @State var showSecondView = false
    @State var showNextView: Bool = false
    @State private var showAlert = false
    var onNextView: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            if !showSecondView {
                FirstDataInputView(patientData: patientData) {
                    self.showSecondView = true
                }
            } else {
                SecondDataInputView(patientData: patientData) {
                    dataService.setPatientData(patientData: self.patientData)
                    onNextView?()
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
