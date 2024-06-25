//
//  HeaderViewNotSKT.swift
//  memtest-app
//
//  Created by Max Werzinger on 24.05.24.
//

import SwiftUI

/// `BaseHeaderViewNotSKT` provides a consistent header view for non-SKT tests
///
/// Features:
/// - Displays back and next buttons if the application is in admin mode
/// - Shows an audio indicator if required
///
/// - Parameters:
///   - showAudioIndicator: A Boolean to determine if the audio indicator should be shown.
///   - onBack: A closure to be executed when the back button is pressed.
///   - onNext: A closure to be executed when the next button is pressed.
struct BaseHeaderViewNotSKT: View {
    
    // Boolean to determine if the audio indicator should be shown
    var showAudioIndicator: Bool
    
    // Closure to be executed when the back button is pressed
    var onBack: (() -> Void)
    
    // Closure to be executed when the next button is pressed
    var onNext: (() -> Void)
    
    public init(showAudioIndicator: Bool, onBack: @escaping (() -> Void), onNext: @escaping (() -> Void)) {
        self.showAudioIndicator = showAudioIndicator
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
