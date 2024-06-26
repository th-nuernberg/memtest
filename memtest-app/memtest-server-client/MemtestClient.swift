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
    
    public func checkHealth() async throws {
        let response = try await client.api_period_health_period_health_check()
        switch response {
        case .ok:
            return
        default:
            throw MemtestClientError.serverHealthCheckFailed
        }
    }
    
    public func uploadTestResult(testResult: Components.Schemas.TestResult) async throws {
        let response = try await client.api_period_test_result_period_upload_test_result(.init(body: .json(testResult)))
        
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
    case serverHealthCheckFailed
    
    var localizedDescription: String {
        switch self {
        case .serverUrlNotFound:
            return "Server URL konnte nicht gefunden werden."
        case .uploadFailed:
            return "Hochladen des Testergebnisses fehlgeschlagen."
        case .serverHealthCheckFailed:
            return "Der Server antwortet nicht. Ist eine Internetverbindung vorhanden?"
        }
    }
}
