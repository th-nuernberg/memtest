//
//  SecondDataInputView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.04.24.
//

import SwiftUI

/// `SecondDataInputView` handles the second step of patient data input
///
/// Features:
/// - Collects additional patient data including medical information, dementia severity, depression severity, and additional diagnoses
///
/// - Parameters:
///   - patientData: The `PatientData` object to store the input data
///   - finished: A closure to be executed when the user completes this step
struct SecondDataInputView: View {
    @ObservedObject var patientData: PatientData
    var finished: () -> ()
    
    var body: some View {
        Form {
            Section(header: Text("Weitere medizinische Informationen").font(.title3)) {
                CheckboxView(label: "Haben Sie Sehprobleme", isChecked: $patientData.hasVisionProblems)
                CheckboxView(label: "Haben Sie Hörprobleme", isChecked: $patientData.hasHearingProblems)
            }
            .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            
            Section(header: Text("Demenz Schweregrad:").font(.title3)) {
                ForEach(Severity.allCases, id: \.self) { severity in
                    RadioButtonView(selectedValue: $patientData.dementiaSeverity, value: severity)
                }
            }
            .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            
            Section(header: Text("Depression Schweregrad:").font(.title3)) {
                ForEach(Severity.allCases, id: \.self) { severity in
                    RadioButtonView(selectedValue: $patientData.depressionSeverity, value: severity)
                }
            }
            .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            
            TextField("Zusätzliche relevante Diagnosen", text: $patientData.additionalDiagnoses)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            HStack {
                Spacer()
                Button(action: {
                    self.finished()
                }) {
                    Text("Zur Einführung")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(10)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 100)
                Spacer()
            }
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SecondDataInputView(patientData: PatientData()) {
        // Closure action
    }
}
