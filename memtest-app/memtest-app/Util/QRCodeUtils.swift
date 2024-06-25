//
//  QRCodeUtils.swift
//  memtest-app
//
//  Created by Christopher Witzl on 29.02.24.
//

import Foundation

// The struct for storing the retriving the data from the qrcode
public struct QRCodeData: Codable {
    public var study_id: String
    public var id: String
    public var key: String
    
    public init(study_id: String, id: String, key: String) {
        self.study_id = study_id
        self.id = id
        self.key = key
    }
}
// Used for decoding the qrcode data
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
