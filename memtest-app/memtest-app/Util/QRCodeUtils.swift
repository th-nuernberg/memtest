//
//  QRCodeUtils.swift
//  memtest-app
//
//  Created by Christopher Witzl on 29.02.24.
//

import Foundation

public struct QRCodeData: Codable {
    public var id: String
    public var publicKey: String
    public var privateKey: String
    
    // Ein öffentlicher Initialisierer ist notwendig, wenn Sie Strukturen außerhalb ihres eigenen Moduls instanziieren möchten.
    public init(id: String, publicKey: String, privateKey: String) {
        self.id = id
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}

public func decodeQRCodeString(_ qrCodeString: String) -> QRCodeData? {
    let jsonData = Data(qrCodeString.utf8)
    let decoder = JSONDecoder()
    
    do {
        let qrData = try decoder.decode(QRCodeData.self, from: jsonData)
        return qrData
    } catch {
        print("Fehler beim Parsen des QR-Codes: \(error)")
        return nil
    }
}
