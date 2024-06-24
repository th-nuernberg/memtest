//
//  HeaderViewNotSKT.swift
//  memtest-app
//
//  Created by Max Werzinger on 24.05.24.
//


import SwiftUI

struct BaseHeaderViewNotSKT: View {
    
    var showAudioIndicator: Bool
    
    var onBack: (() -> Void)
    var onNext: (() -> Void)
    
    public init(showAudioIndicator: Bool, onBack: @escaping (() -> Void), onNext: @escaping (() -> Void)) {
        self.showAudioIndicator = showAudioIndicator
        self.onBack = onBack
        self.onNext = onNext
    }
    
    var body: some View {
        
        HStack {
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
            
            if(showAudioIndicator){
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

