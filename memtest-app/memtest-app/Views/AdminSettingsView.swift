//
//  AdminSettingsView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 30.05.24.
//

import SwiftUI

struct AdminSettingsView: View {
    var onNextView: (() -> Void)?

    @State private var testDuration = SettingsService.shared.test_duration
    @State private var soundEnabled = SettingsService.shared.sound_enabled
    @State private var showingDeleteConfirmation = false  // To control the alert visibility

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    SettingsService.shared.test_duration = testDuration
                    SettingsService.shared.sound_enabled = soundEnabled
                    onNextView?()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    showingDeleteConfirmation = true  // Show confirmation alert
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Gespeicherte Testergebnisse löschen")
                    }
                    .foregroundColor(.red)
                    .padding()
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            List {
                Section(header: Text("Allgemeine Einstellungen")) {
                    HStack {
                        Text("Test Dauer: ")
                        Spacer()
                        TextField("Duration", value: $testDuration, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Toggle("Ton deaktivieren", isOn: $soundEnabled)
                }
            }
            .listStyle(GroupedListStyle())
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Bestätigung"),
                message: Text("Sind Sie sicher, dass Sie alle gespeicherten Testergebnisse löschen möchten?"),
                primaryButton: .destructive(Text("Löschen")) {
                    deleteAllFiles()
                },
                secondaryButton: .cancel(Text("Abbrechen"))
            )
        }
    }
    
    func deleteAllFiles() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents path not found.")
            return
        }
        
        let fileManager = FileManager.default
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            for filePath in filePaths {
                try fileManager.removeItem(at: filePath)
            }
            print("All files deleted.")
        } catch {
            print("Could not clear documents folder: \(error)")
        }
    }
}

#Preview {
    AdminSettingsView()
}
