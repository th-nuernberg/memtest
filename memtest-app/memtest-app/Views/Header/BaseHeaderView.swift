//
//  BaseHeaderView.swift
//  memtest-app
//
//  Created by Max Werzinger on 23.05.24.
//

import SwiftUI

/// `BaseHeaderView` provides a consistent header view across different tests
///
/// Features:
/// - Displays back and next buttons if the application is in admin mode
/// - Shows an audio indicator if required
///
/// - Parameters:
///   - showAudioIndicator: A Boolean to determine if the audio indicator should be shown.
///   - currentView: A binding to manage the current view state.
///   - onBack: A closure to be executed when the back button is pressed. --> should be used to go back to the last test
///   - onNext: A closure to be executed when the next button is pressed. --> should be used to go to the next test
struct BaseHeaderView: View {
    
    @Binding var currentView: SKTViewEnum

    // Boolean to determine if the audio indicator should be shown
    var showAudioIndicator: Bool
    
    // Closure to be executed when the back button is pressed
    var onBack: (() -> Void)
    
    // Closure to be executed when the next button is pressed
    var onNext: (() -> Void)
    
    public init(showAudioIndicator: Bool, currentView: Binding<SKTViewEnum>, onBack: @escaping (() -> Void), onNext: @escaping (() -> Void)) {
        self.showAudioIndicator = showAudioIndicator
        self._currentView = currentView
        self.onBack = onBack
        self.onNext = onNext
    }
    
    var body: some View {
        HStack {
            // check if admin mode is activated
            if SettingsService.shared.isAdminMode() {
                Button(action: {
                    onBack()
                }) {
                    Text("Zurück")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal, 50)
                .background(Color.blue)
                .cornerRadius(10)
                .navigationBarBackButtonHidden(true)
            }
            
            Spacer()
            
            if showAudioIndicator {
                AudioIndicatorView()
            }
            
            Spacer()
            
            if SettingsService.shared.isAdminMode() {
                Button(action: {
                    onNext()
                }) {
                    Text("Weiter")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal, 50)
                .background(Color.blue)
                .cornerRadius(10)
                .navigationBarBackButtonHidden(true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
