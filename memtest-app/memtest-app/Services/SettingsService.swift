//
//  SettingsService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 29.05.24.
//

import Foundation

// Singleton service for providing general settings
class SettingsService {
    static let shared = SettingsService()
    private var adminMode = false
    
    public var test_duration = 60
    // currently there is no sound used for the avatar
    public var sound_enabled = true
    
    private init() {}
    
    func setAdminMode(debugMode: Bool) {
        self.adminMode = debugMode
    }
    
    func toggleAdminMode() -> Void {
        self.adminMode.toggle()
    }
    
    func isAdminMode() -> Bool {
        return self.adminMode
    }
    
    func getTestDuration() -> Int {
        return self.test_duration
    }
}
