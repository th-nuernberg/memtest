//
//  DataService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 18.04.24.
//

import Foundation

class DataService {
    static let shared = DataService()
    
    private var study_id: String = ""
    private var uuid: String = ""
    private var aes_key: String = ""
    
    
    func setQRCodeData(qrCodeData: QRCodeData){
        study_id = qrCodeData.study_id
        uuid = qrCodeData.id
        aes_key = qrCodeData.key
    }
    
    func getStudyId() -> String {
        return self.study_id
    }
    
}
