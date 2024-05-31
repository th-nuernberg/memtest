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
    
    // Metadata
    private var study_id: String = ""
    private var uuid: String = ""
    private var aes_key: String = ""
    
    private var patientData: PatientData?
    
    private var calibrated: Bool = false
    
    private var skt = SKTResults()
    
    private var vft = VFTResults()
    private var bnt = BNTResults()
    private var pdt = PDTResults()
    
    private init() {
        
    }
    
    // MARK: Setting data
    
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
    func saveVFTResults(recognizedAnimalNames: [String]) {
        self.vft.finished = true
        self.vft.recognizedAnimalNames = recognizedAnimalNames
    }
    // BNT
    func saveBNTResults(recognizedObjectNames: [String]) {
        self.bnt.finished = true
        self.bnt.recognizedObjectNames = recognizedObjectNames
    }
    // PDT
    func savePDTResults(){
        self.pdt.finished = true
    }
    
    // MARK: CHECKS
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
        return self.vft.finished
    }
    // BNT
    func hasBNTFinished() -> Bool {
        return self.bnt.finished
    }
    // PDT
    func hasPDTFinished() -> Bool {
        return self.pdt.finished
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
