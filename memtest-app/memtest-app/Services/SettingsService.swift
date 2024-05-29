//
//  SettingsService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 29.05.24.
//

import Foundation

class SettingsService {
    static let shared = SettingsService()
    
    
    private var adminMode = false
    
    private init() {
        
    }
    
    func setAdminMode(debugMode: Bool) {
        self.adminMode = debugMode
    }
    
    func toggleAdminMode() -> Void {
        self.adminMode.toggle()
    }
    
    func isAdminMode() -> Bool {
        return self.adminMode
    }
    
}
