//
//  FirstDataInputView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.04.24.
//

import SwiftUI
import Combine

/// `FirstDataInputView` handles the first step of patient data input
///
/// Features:
/// - Collects initial patient data including age, educational qualification, and gender
/// - Validates the input data
///
/// - Parameters:
///   - patientData: The `PatientData` object to store the input data
///   - finished: A closure to be executed when the user completes this step
struct FirstDataInputView: View {
    @ObservedObject var patientData: PatientData
    @State private var showAlert = false
    var finished: () -> ()
    
    var body: some View {
        Form {
            Section(header: Text("Alter des Teilnehmers:").font(.title)) {
                HStack {
                    TextField("Alter eingeben", text: $patientData.age)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        // This is for filtering out invalid ages
                        .onChange(of: patientData.age) { oldValue, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if let ageInt = Int(filtered), ageInt > 200 {
                                // Removes the last character if over 200
                                patientData.age = String(filtered.dropLast())
                            } else if patientData.age != filtered {
                                patientData.age = filtered
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            
            Section(header: Text("Höchster Bildungsabschluss des Teilnehmers:").font(.title)) {
                ForEach(EducationalQualification.allCases, id: \.self) { degree in
                    RadioButtonView(selectedValue: $patientData.selectedDegree, value: degree)
                }
            }
            .padding(.horizontal, 20)
            
            Section(header: Text("Geschlecht des Teilnehmers:").font(.title)) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    RadioButtonView(selectedValue: $patientData.selectedGender, value: gender)
                }
            }
            .padding(.horizontal, 20)
            
            HStack {
                Spacer()
                Button(action: {
                    if self.patientData.age.isEmpty {
                        showAlert = true
                    } else {
                        self.finished()
                    }
                }) {
                    Text("Weiter")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(10)
                .background(patientData.age.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 100)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Fehler"), message: Text("Bitte füllen Sie alle Felder aus."))
                }
                Spacer()
            }
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    FirstDataInputView(patientData: PatientData()) {
        // Closure action
    }
}
