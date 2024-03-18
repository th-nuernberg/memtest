//
//  DataInputView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI
import Combine

struct DataInputView: View {
  @State private var age = ""
  @State private var selectedDegree: EducationalQualification = .noDegree
  @State var showNextView: Bool = false
  @State private var showAlert = false

  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Alter:")
        TextField("Alter eingeben", text: $age)
          .keyboardType(.numberPad) // Ensures numeric input
          .padding()
          .background(Color.gray.opacity(0.2))
          .cornerRadius(10)
          .onReceive(Just(age)) { newValue in  // Use Just(age) to create a publisher
            let filtered = String(newValue.filter { $0.isNumber }) // Filter non-numeric characters

            // Enforce maximum value (200)
            if let ageInt = Int(filtered), ageInt > 200 {
              age = String(filtered.prefix(filtered.count - 1)) // Remove last character if exceeding limit
            } else {
              age = filtered // Update age with filtered value
            }
          }
      }

        Section(header: Text("Höchster Bildungsabschluss").font(.title)) {
          ForEach(EducationalQualification.allCases) { degree in
            HStack {
              RadioButton(selectedDegree: $selectedDegree, degree: degree)
              Text(degree.rawValue)
            }
          }
        }

      Button(action: {
        if age.isEmpty {
          showAlert = true
        } else {
          //TODO: add metaInformation(age/degree) to file
          print("Alter: \(age)")
          print("Abschluss: \(selectedDegree.rawValue)")
          showNextView.toggle()
        }
      }) {
        Text("Weiter")
      }
      .disabled(age.isEmpty)
      .foregroundColor(age.isEmpty ? .gray : .blue)
      .navigationBarBackButtonHidden(true)
      .navigationDestination(isPresented: $showNextView) {
        TestExplinationDragDropView()
      }
      .alert(isPresented: $showAlert) {
        Alert(title: Text("Fehler"), message: Text("Bitte füllen Sie alle Felder aus."))
      }
    }
    .padding()
  }
}

struct RadioButton: View {
  @Binding var selectedDegree: EducationalQualification
  let degree: EducationalQualification

  var body: some View {
    Circle()
      .foregroundColor(selectedDegree == degree ? .blue : .gray)
      .frame(width: 20, height: 20)
      .onTapGesture {
        selectedDegree = degree
      }
  }
}

enum EducationalQualification: String, Identifiable {
  case noDegree = "Kein Abschluss"
  case schoolOrApprenticeship = "Schulabschluss, Ausbildungsberuf"
  case technicianMasterOrUniversity = "Techniker, Meister oder Hochschulabschluss"

  static var allCases: [EducationalQualification] {
    return [.noDegree, .schoolOrApprenticeship, .technicianMasterOrUniversity]
  }

  var id: String {
    return rawValue
  }
}

/*
 #Preview {
 DataInputView()
 }
*/
