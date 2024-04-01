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
    @State private var selectedGender: Gender = .male
    @State var showNextView: Bool = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack{
            Form {
                Section(header: Text("Informationsabfrage").font(.system(size: 40))) {
                }
                
                Section(header: Text("Alter des Teilnehmers:").font(.title)){
                    HStack{
                        TextField("Alter eingeben", text: $age)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onReceive(Just(age)) { newValue in
                                let filtered = String(newValue.filter { $0.isNumber })
                                if let ageInt = Int(filtered), ageInt > 200 {
                                    age = String(filtered.prefix(filtered.count - 1))
                                } else {
                                    age = filtered
                                }
                            }
                    }
                    
                }
                .padding(.horizontal,20)
                
                Section(header: Text("Höchster Bildungsabschluss des Teilnehmers:").font(.title)) {
                    ForEach(EducationalQualification.allCases) { degree in
                        HStack {
                            RadioButtonDegree(selectedDegree: $selectedDegree, degree: degree)
                            Text(degree.rawValue)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .padding(.horizontal,20)
                
                Section(header: Text("Geschlecht des Teilnehmers:").font(.title)) {
                    ForEach(Gender.allCases) { gender in
                        HStack {
                            RadioButtonGender(selectedGender: $selectedGender, gender: gender)
                            Text(gender.rawValue)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .padding(.horizontal,20)
                
                
            }
            .scrollContentBackground(Visibility.hidden)
            
            
            
            Button(action: {
                if age.isEmpty {
                    showAlert = true
                } else {
                    //TODO: add metaInformation(age/degree) to file
                    // Alter --> age
                    // Abschluss --> selectedDegree
                    // Geschlecht --> selectedGender
                    showNextView.toggle()
                }
            }) {
                Text("Zur Einführung")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .padding(10)
            .background(age.isEmpty ? Color.gray : Color.blue)
            .cornerRadius(10)
            .padding(.bottom,100)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showNextView) {
                TestExplinationDragDropView()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Fehler"), message: Text("Bitte füllen Sie alle Felder aus."))
            }
        }
    }
}

struct RadioButtonDegree: View {
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

struct RadioButtonGender: View {
    @Binding var selectedGender: Gender
    let gender: Gender
    
    var body: some View {
        Circle()
            .foregroundColor(selectedGender == gender ? .blue : .gray)
            .frame(width: 20, height: 20)
            .onTapGesture {
                selectedGender = gender
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

enum Gender: String, Identifiable {
    case male = "Männlich"
    case female = "Weiblich"
    
    static var allCases: [Gender] {
        return [.male, .female]
    }
    
    var id: String {
        return rawValue
    }
}

#Preview {
    DataInputView()
}
