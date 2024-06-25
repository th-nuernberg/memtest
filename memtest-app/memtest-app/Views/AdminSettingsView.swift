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
    @State private var showingDeleteConfirmation = false
    @State private var secretKey = ""
    @State private var saveStatusMessage: String? = nil

    var body: some View {
        VStack {
            topBar
            
            List {
                generalSettingsSection
                securitySettingsSection
            }
            .listStyle(GroupedListStyle())
            
            Spacer()

            saveStatusView
        }
        .alert(isPresented: $showingDeleteConfirmation, content: deleteConfirmationAlert)
    }
    
    var topBar: some View {
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
                showingDeleteConfirmation = true
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
    }
    
    var generalSettingsSection: some View {
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
    
    var securitySettingsSection: some View {
        Section(header: Text("Sicherheitseinstellungen")) {
            VStack(alignment: .leading) {
                Text("Bitte geben Sie das Studien-Secret ein.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                SecureField("Studien-Secret", text: $secretKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Speichern") {
                    saveSecret()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    var saveStatusView: some View {
        Group {
            if let message = saveStatusMessage {
                Text(message)
                    .foregroundColor(.green)
                    .transition(.slide)
                    .padding()
            } else {
                EmptyView()
            }
        }
    }
    
    func saveSecret() {
        let saved = KeychainService.shared.save(secret: secretKey, for: "study-secret")
        if saved {
            saveStatusMessage = "Secret erfolgreich gespeichert."
        } else {
            saveStatusMessage = "Fehler beim Speichern des Secrets."
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            saveStatusMessage = nil
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
    
    func deleteConfirmationAlert() -> Alert {
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

#Preview {
    AdminSettingsView()
}
