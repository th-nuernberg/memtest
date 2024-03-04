//
//  DataInputView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct DataInputView: View {
    @State var showNextView: Bool = false
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var selectedDegree: EducationalQualification = .noDegree
    
    @State private var showAlert = false
    
    var body: some View {
            HStack{
                Text("Vorname")
                    .font(.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.trailing,10)
                
                TextField("Vorname eingeben", text: $firstName)
                    .frame(width: 600)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            
            HStack{
                Text("Nachname")
                    .font(.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.trailing,10)
                
                TextField("Nachname eingeben", text: $lastName)
                    .frame(width: 600)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            
            HStack{
                Text("Alter")
                    .font(.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.trailing,10)
                
                TextField("Alter eingeben", text: $age)
                    .keyboardType(.numberPad)
                    .frame(width: 600)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            
            VStack{
                Text("Höchster Bildungsabschluss")
                    .font(.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.trailing,10)
                
                ForEach(EducationalQualification.allCases) {
                    degree in
                    HStack {
                        Circle()
                            .foregroundColor(selectedDegree == degree ? .blue : .gray)
                            .frame(width: 20,height: 20)
                            .onTapGesture {
                                selectedDegree = degree
                            }
                        Text(degree.rawValue)
                    }
                    .id(degree.id)
                    .frame(maxWidth: .infinity,alignment: .leading)
                }
            }
            .padding()
            
            NavigationStack {
                VStack{
                    Button{
                        if firstName.isEmpty || lastName.isEmpty || age.isEmpty {
                            showAlert = true
                        } else {
                            print("Vorname: " + firstName)
                            print("Nachname: " + lastName)
                            print("Alter: " + age)
                            print("Abschluss: " + selectedDegree.rawValue)
                            showNextView.toggle()
                        }
                    }label: {
                        Text("Zur nächsten View")
                    }
                    .navigationDestination(isPresented: $showNextView) {
                        TestExplinationDragDropView()
                    }
                    .navigationBarBackButtonHidden(true)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Fehler"), message: Text("Bitte füllen Sie alle Felder aus."))
                }
            }
        }
    }

enum EducationalQualification: String,Identifiable {
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

#Preview {
    DataInputView()
}
