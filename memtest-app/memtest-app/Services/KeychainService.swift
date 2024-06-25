//
//  KeychainService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 24.06.24.
//

import Foundation
import Security

/// `KeychainService` - Singleton  currently provides a secure mechanism for storing and retrieving the study-secret, but can be used for other security related values
class KeychainService {
    
    static let shared = KeychainService()
    
    /// Saves a secret in the Keychain.
    /// - Parameters:
    ///   - secret: The secret text to be stored as `String`.
    ///   - account: The key or identifier under which the secret should be stored.
    /// - Returns: A Boolean value indicating whether the save operation was successful.
    func save(secret: String, for account: String) -> Bool {
        let data = Data(secret.utf8)
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary) // trying to delete value if exists
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    /// Loads a secret from the Keychain.
    /// - Parameter account: The key or identifier under which the secret is stored.
    /// - Returns: The secret as a `String` if it exists and can be retrieved; otherwise, `nil`.
    func loadSecret(for account: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else { return nil }
        guard let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
