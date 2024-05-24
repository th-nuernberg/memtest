//
//  DataService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 18.04.24.
//

import Foundation
import Zip

class DataService {
    static let shared = DataService()
    
    // APP - Settings
    private var debugMode = false
    
    // Metadata
    private var study_id: String = ""
    private var uuid: String = ""
    private var aes_key: String = ""
    
    private var patientData: PatientData?
    
    private var calibrated: Bool = false
    
    // SKT-Data
    
    
    // VFT-Data
    private var vftFinished: Bool = false
    private var recognizedAnimalNames: [String] = []
    // BNT-Data
    private var bntFinished: Bool = false
    private var recognizedObjectNames: [String] = []
    // PDT-Data
    private var pdtFinished: Bool = false
    
    private init() {
        
    }
    
    // MARK: Setting data
    
    // App - Settings
    func setDebugMode(debugMode: Bool) {
        self.debugMode = debugMode
    }
    
    // Metadata
    
    func setQRCodeData(qrCodeData: QRCodeData){
        study_id = qrCodeData.study_id
        uuid = qrCodeData.id
        aes_key = qrCodeData.key
    }
    
    func setPatientData(patientData: PatientData) {
        self.patientData = patientData
    }
    
    func getStudyId() -> String {
        return self.study_id
    }
    
    
    func setCalibrated(calibrated: Bool) {
        self.calibrated = calibrated
    }
    // SKT
    
    // VFT
    func setRecognizedAnimalNames(names: [String]) {
        self.vftFinished = true
        self.recognizedAnimalNames = names
    }
    // BNT
    func setRecognizedObjectNames(names: [String]) {
        self.bntFinished = true
        self.recognizedObjectNames = names
    }
    // PDT
    func setPDTFinished() {
        self.pdtFinished = true
    }
    
    // MARK: CHECKS
    // App - Settings
    func isDebugMode() -> Bool {
        return self.debugMode
    }
    
    func toggleDebugMode() -> Void {
        self.debugMode.toggle()
    }
    
    //Metadata
    
    func hasQRCodeScanned() -> Bool {
        return (uuid != "" && aes_key != "" )
    }
    
    func hasMetadataBeenCollected() -> Bool {
        return (patientData != nil)
    }
    
    func hasCalibrated() -> Bool {
        return self.calibrated
    }
    
    // SKT
    
    
    // VFT
    func hasVFTFinished() -> Bool {
        return self.vftFinished
    }
    // BNT
    func hasBNTFinished() -> Bool {
        return self.bntFinished
    }
    // PDT
    func hasPDTFinished() -> Bool {
        return self.pdtFinished
    }
    
    // Zipping
    func saveDataToJsonFiles() {
        print("save data")
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.uuid = "testergebnis_2"
        let uuidDirectory = documentsDirectory.appendingPathComponent(uuid)
        
        print(uuidDirectory)
        
        // Create the directory if it does not exist
        if !fileManager.fileExists(atPath: uuidDirectory.path) {
            do {
                try fileManager.createDirectory(at: uuidDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error)")
                return
            }
        }

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        // Save QRCodeData
        let qrPath = uuidDirectory.appendingPathComponent("QRCodeData.json")
        if let qrData = try? jsonEncoder.encode(QRCodeData(study_id: self.study_id, id: self.uuid, key: self.aes_key)) {
            do {
                try qrData.write(to: qrPath)
            } catch {
                print("Failed to write QRCodeData: \(error)")
            }
        }

        // Save PatientData
        let patientPath = uuidDirectory.appendingPathComponent("PatientData.json")
        if let patientData = self.patientData,
           let patientDataEncoded = try? jsonEncoder.encode(patientData) {
            do {
                try patientDataEncoded.write(to: patientPath)
            } catch {
                print("Failed to write PatientData: \(error)")
            }
        }
        
        print(try! Zip.quickZipFiles([uuidDirectory], fileName: "\(uuid)_encrypted"))
    }


}
