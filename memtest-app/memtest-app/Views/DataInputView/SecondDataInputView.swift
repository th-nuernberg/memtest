//
//  SecondDataInputView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.04.24.
//

import SwiftUI

struct SecondDataInputView: View {
    @ObservedObject var patientData: PatientData

    var body: some View {
        Form {
            Section(header: Text("Weitere medizinische Informationen")) {
                CheckboxView(label: "Haben Sie Sehprobleme", isChecked: $patientData.hasVisionProblems)
                CheckboxView(label: "Haben Sie Hörprobleme", isChecked: $patientData.hasHearingProblems)

                Text("Demenz Schweregrad:")
                ForEach(Severity.allCases, id: \.self) { severity in
                    RadioButtonView(selectedValue: $patientData.dementiaSeverity, value: severity)
                }

                Text("Depression Schweregrad:")
                ForEach(Severity.allCases, id: \.self) { severity in
                    RadioButtonView(selectedValue: $patientData.depressionSeverity, value: severity)
                }

                TextField("Zusätzliche relevante Diagnosen", text: $patientData.additionalDiagnoses)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .scrollContentBackground(.hidden)
        
       
    }
}



#Preview {
    SecondDataInputView(patientData: PatientData())
}
