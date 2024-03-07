//
//  MemtestClient.swift
//  memtest-server-client
//
//  Created by Christopher Witzl on 07.03.24.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public struct MemtestClient {
    let client: Client
    
    public init() throws {
        // Sichereres Unwrapping mit Fehlerbehandlung
        guard let serverURL = try? Servers.server1() else {
            throw MemtestClientError.serverUrlNotFound
        }
        self.client = Client(serverURL: serverURL, transport: URLSessionTransport())
    }
    
    public func uploadTestResult(testResult: Components.Schemas.TestResult) async throws {
        let response = try await client.uploadTestResult(.init(body: .json(testResult)))
        
        switch response {
        case .ok:
            return 
        default:
            throw MemtestClientError.uploadFailed
        }
    }
}

enum MemtestClientError: Error {
    case serverUrlNotFound
    case uploadFailed
    
    var localizedDescription: String {
        switch self {
        case .serverUrlNotFound:
            return "Server URL konnte nicht gefunden werden."
        case .uploadFailed:
            return "Hochladen des Testergebnisses fehlgeschlagen."
        }
    }
}
