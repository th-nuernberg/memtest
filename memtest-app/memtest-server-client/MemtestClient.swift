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
        // Determine the server URL based on the build configuration
        #if DEBUG
        guard let serverURL = try? Servers.server2() else {
            throw MemtestClientError.serverUrlNotFound
        }
        print("DEBUG mode: Using endpoint with url: \(serverURL)")
        #else
        guard let serverURL = try? Servers.server2() else {
            throw MemtestClientError.serverUrlNotFound
        }
        print("RELEASE mode: Using endpoint with url: \(serverURL)")
        #endif

        self.client = Client(serverURL: serverURL, transport: URLSessionTransport())
    }
    
    public func checkHealth() async throws {
        
        do {
            let response = try await client.get_health_status()
            if case .ok = response {
            } else {
                print("Server returned unexpected status.")
                throw MemtestClientError.serverHealthCheckFailed
            }
        } catch {
           print("Health check failed with error: \(error)")
           throw error
        }
         
    }
    

    
    public func uploadTestResult(uuid: String, fileData: Data) async throws {
        // Convert Data to ArraySlice<UInt8>
        let byteChunk = ArraySlice<UInt8>(fileData)
        // Create HTTPBody using the byteChunk
        let httpBody = HTTPBody(byteChunk, length: .known(Int64(fileData.count)))
        // Create requestBody with the newly created HTTPBody
        let requestBody = Operations.upload_test_result.Input.Body.application_zip(httpBody)

        let response = try await client.upload_test_result(query: .init(qrcode_hyphen_uuid: uuid), body: requestBody)
        
        switch response {
        case .ok(_): break
        
        case .conflict(_):
            throw MemtestClientError.alreadyExists
            
        case .undocumented(statusCode: let statusCode, _):
            throw MemtestClientError.serverError(statusCode: statusCode, message: "An undocumented server error occurred.")
        }
    }
}

public enum MemtestClientError: Error {
    case serverUrlNotFound
    case uploadFailed
    case alreadyExists
    case serverHealthCheckFailed
    case serverError(statusCode: Int, message: String)
}

extension MemtestClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverUrlNotFound:
            return "Server URL konnte nicht gefunden werden."
        case .uploadFailed:
            return "Hochladen des Testergebnisses fehlgeschlagen."
        case .alreadyExists:
            return "Das Testergebnis mit der UUID gibt es bereits!."
        case .serverHealthCheckFailed:
            return "Der Server antwortet nicht. Ist eine Internetverbindung vorhanden?"
        case .serverError(let statusCode, let message):
            return "Serverfehler \(statusCode): \(message)"
        }
    }

    public var failureReason: String? {
        switch self {
        case .serverError(let statusCode, _):
            return "Fehlercode: \(statusCode)"
        default:
            return nil
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .uploadFailed:
            return "Bitte überprüfen Sie die Netzwerkverbindung und versuchen Sie es erneut."
        default:
            return "Bitte kontaktieren Sie den Support."
        }
    }
}
