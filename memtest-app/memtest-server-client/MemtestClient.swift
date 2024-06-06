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
        guard let serverURL = try? Servers.server1() else {
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
        let response = try await client.get_health_status()
        switch response {
        case .ok:
            return
        default:
            throw MemtestClientError.serverHealthCheckFailed
        }
    }
    

    
    public func uploadTestResult(uuid: String, fileData: Data) async throws {
        
        let uuid_path = Operations.upload_test_result.Input.Path(qrcode_hyphen_uuid: uuid)
        
        // Convert Data to ArraySlice<UInt8>
        let byteChunk = ArraySlice<UInt8>(fileData)
        // Create HTTPBody using the byteChunk
        let httpBody = HTTPBody(byteChunk, length: .known(Int64(fileData.count)))
        // Create requestBody with the newly created HTTPBody
        let requestBody = Operations.upload_test_result.Input.Body.application_zip(httpBody)

        
        let response = try! await client.upload_test_result(path: uuid_path, body: requestBody)
        print(response)
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
