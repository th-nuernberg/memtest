//
//  AdminSettingsView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 30.05.24.
//

import SwiftUI

struct AdminSettingsView: View {
    var onNextView: (() -> Void)?
    
    @State var testDuration = SettingsService.shared.test_duration
    @State var soundEnabled = SettingsService.shared.sound_enabled

    var body: some View {
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
}

#Preview {
    AdminSettingsView()
}
