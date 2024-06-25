//
//  DataService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 18.04.24.
//

import Foundation
import ZipArchive
import memtest_server_client


class DataService {
    static let shared = DataService()
    private let client: MemtestClient
    
    // Metadata
    private var study_id: String = ""
    private var uuid: String = ""
    private var aes_key: String = ""
    private var patientData: PatientData?
    
    private var calibrated: Bool = false
    
    private var skt1 = SKT1Results()
    private var skt2 = SKT2Results()
    private var skt3 = SKT3Results()
    private var skt4 = SKT4Results()
    private var skt5 = SKT5Results()
    private var skt6 = SKT6Results()
    private var skt7 = SKT7Results()
    private var skt8 = SKT8Results()
    private var skt9 = SKT9Results()
    
    
    private var vft = VFTResults()
    private var bnt = BNTResults()
    private var pdt = PDTResults()
    
    private init() {
        do {
            self.client = try MemtestClient()
        } catch {
            fatalError("Failed to initialize MemtestClient: \(error)")
        }
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
    
    func getUUID() -> String {
        return self.uuid
    }
    
    func setCalibrated(calibrated: Bool) {
        self.calibrated = calibrated
    }
    
    // TODO: Make saving generic
    // SKT
    func saveSKT1Results(recognizedSymbolNames: [String]) {
        self.skt1.finished = true
        self.skt1.recognizedSymbolNames = recognizedSymbolNames
        
        saveToJson(name: "skt1", data: self.skt1)
    }
    
    func saveSKT2Results(rememberedSymbolNames: [String]) {
        self.skt2.finished = true
        self.skt2.rememberedSymbolNames = rememberedSymbolNames
        
        saveToJson(name: "skt2", data: self.skt2)
    }
    
    func saveSKT3Results() {
        self.skt3.finished = true
    }
    
    func saveSKT4Results(dragElements: [DragElement]) {
        self.skt4.finished = true
        let dragElementsCodable = dragElements.map { DragElementCodable(dragElement: $0) }
        self.skt4.dragElements = dragElementsCodable
        
        saveToJson(name: "skt4", data: self.skt4)
    }
    
    func saveSKT5Results(dragElements: [DragElement]) {
        self.skt5.finished = true
        let dragElementsCodable = dragElements.map { DragElementCodable(dragElement: $0) }
        self.skt5.dragElements  = dragElementsCodable
        
        saveToJson(name: "skt5", data: self.skt5)
    }
    
    func saveSKT6Results(symbolToCount: String, symbolCounts: [String: Int], symbolField: [String], taps: [(Int, String)], userSymbolCount: Int = 0) {
        self.skt6.finished = true
        self.skt6.symbolCounts = symbolCounts
        self.skt6.symbolField = symbolField
        self.skt6.symbolToCount = symbolToCount
        self.skt6.taps  = taps.map { Tap(index: $0.0, label: $0.1) }
        self.skt6.userSymbolCount = userSymbolCount
        
        saveToJson(name: "skt6", data: self.skt6)
    }
    
    func saveSKT7Results() {
        self.skt7.finished = true
    }
    
    func saveSKT8Results(rememberedSymbolNames: [String]) {
        self.skt8.finished = true
        self.skt8.rememberedSymbolNames = rememberedSymbolNames
        
        saveToJson(name: "skt8", data: self.skt8)
    }
    
    func saveSKT9Results(correctlyRememberedSymbolNames: [String]) {
        self.skt9.finished = true
        self.skt9.correctlyRememberedSymbolNames = correctlyRememberedSymbolNames
        
        saveToJson(name: "skt9", data: self.skt9)
    }
    
    // VFT
    func saveVFTResults(recognizedAnimalNames: [String]) {
        self.vft.finished = true
        self.vft.recognizedAnimalNames = recognizedAnimalNames
        
        saveToJson(name: "vft", data: self.vft)
    }
    // BNT
    func saveBNTResults(recognizedObjectNames: [String]) {
        self.bnt.finished = true
        self.bnt.recognizedObjectNames = recognizedObjectNames
        
        saveToJson(name: "bnt", data: self.bnt)
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
    func hasSKTFinished() -> Bool {
        return skt9.finished
    }
    
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
    
    func saveToJson(name: String, data: Codable) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uuidDirectory = documentsDirectory.appendingPathComponent(uuid)
            let testDirectory = uuidDirectory.appendingPathComponent(name)

            if !fileManager.fileExists(atPath: uuidDirectory.path) {
                try fileManager.createDirectory(at: uuidDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            if !fileManager.fileExists(atPath: testDirectory.path) {
                try fileManager.createDirectory(at: testDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            let jsonData = try JSONEncoder().encode(data)
            let jsonFileUrl = testDirectory.appendingPathComponent("\(name).json")
            try jsonData.write(to: jsonFileUrl)
        } catch {
            print("Failed to save \(name): \(error)")
        }
    }
    
    func zipTestResults() {
        guard !uuid.isEmpty, !aes_key.isEmpty else {
            print("UUID or AES key is empty, cannot zip the folder.")
            return
        }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uuidDirectory = documentsDirectory.appendingPathComponent(uuid)
        let zipFilePath = documentsDirectory.appendingPathComponent("\(uuid).zip").path
        
        let success = SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: uuidDirectory.path, withPassword: aes_key)
        
        if success {
            print("Successfully created ZIP file at path: \(zipFilePath)")
        } else {
            print("Failed to create ZIP file.")
        }
    }
    
    func reset() {
        deleteAllFiles()
        
        study_id = ""
        uuid = ""
        aes_key = ""
        
        patientData = nil
        calibrated = false
        
        skt1 = SKT1Results()
        skt2 = SKT2Results()
        skt3 = SKT3Results()
        skt4 = SKT4Results()
        skt5 = SKT5Results()
        skt6 = SKT6Results()
        skt7 = SKT7Results()
        skt8 = SKT8Results()
        skt9 = SKT9Results()
        
        vft = VFTResults()
        bnt = BNTResults()
        pdt = PDTResults()
    }
    
    func deleteAllFiles() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents path not found.")
            return
        }
        let fileManager = FileManager.default
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            for filePath in filePaths {
                if filePath.pathExtension != "zip" {
                    try fileManager.removeItem(at: filePath)
                }
            }
            print("All non-zip files and folders deleted.")
        } catch {
            print("Could not clear documents folder: \(error)")
        }
    }
    
    public func isServerConnectionHealthy() async -> Bool {
        do {
            try await client.checkHealth()
            return true
        } catch {
            return false
        }
    }
    
    public func uploadAllZipFiles() async -> String? {
        zipTestResults()

        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        
        var failedUploads: [String] = []
        
        // Retrieve the secret from the Keychain
        guard let studySecret = KeychainService.shared.loadSecret(for: "study-secret") else {
           return "Failed to retrieve the study secret"
        }
           
        
        do {
            let zipFiles = try fileManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "zip" }
            for zipFile in zipFiles {
                do {
                    let fileData = try Data(contentsOf: zipFile)
                    let uuid = zipFile.deletingPathExtension().lastPathComponent
                    try await client.uploadTestResult(uuid: uuid, fileData: fileData, studySecret: studySecret)
                    try fileManager.removeItem(at: zipFile)
                    
                    // Reset if current testresult upload is successful
                    if (uuid == self.uuid) {
                        reset()
                    }
                } catch {
                    // If an error occurs, add this file to the failedUploads list
                    failedUploads.append(zipFile.lastPathComponent)
                }
            }
            
            if failedUploads.isEmpty {
                return nil
            } else {
                return "Failed to upload files: \(failedUploads.joined(separator: ", "))"
            }
        } catch {
            // This captures errors in fetching the directory contents or filtering
            return "Error accessing zip files: \(error.localizedDescription)"
        }
    }
}
