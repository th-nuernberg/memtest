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
    private var uuid: String = "test-uuid"
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
    func saveSKT1Results(recognizedSymbolNames: [String]) {
        self.skt1.finished = true
        print(recognizedSymbolNames)
        self.skt1.recognizedSymbolNames = recognizedSymbolNames
        
        try! saveToJson(name: "skt1", data: self.skt1)
    }
    
    func saveSKT2Results(rememberedSymbolNames: [String]) {
        self.skt2.finished = true
        print(rememberedSymbolNames)
        self.skt2.rememberedSymbolNames = rememberedSymbolNames
        
        try! saveToJson(name: "skt2", data: self.skt2)
    }
    
    func saveSKT3Results() {
        self.skt3.finished = true
    }
    
    func saveSKT4Results(dragElements: [DragElement]) {
        self.skt4.finished = true
        
        let dragElementsCodable = dragElements.map { DragElementCodable(dragElement: $0) }
        
        self.skt4.dragElements = dragElementsCodable
        
        try! saveToJson(name: "skt4", data: self.skt4)
    }
    
    func saveSKT5Results(dragElements: [DragElement]) {
        self.skt5.finished = true
        let dragElementsCodable = dragElements.map { DragElementCodable(dragElement: $0) }
        self.skt5.dragElements  = dragElementsCodable
        
        try! saveToJson(name: "skt5", data: self.skt5)
    }
    
    func saveSKT6Results(symbolToCount: String, symbolCounts: [String: Int], symbolField: [String], taps: [(Int, String)], userSymbolCount: Int = 0) {
        self.skt6.finished = true
        self.skt6.symbolCounts = symbolCounts
        self.skt6.symbolField = symbolField
        self.skt6.symbolToCount = symbolToCount
        self.skt6.taps  = taps.map { Tap(index: $0.0, label: $0.1) }
        self.skt6.userSymbolCount = userSymbolCount
        
        try! saveToJson(name: "skt6", data: self.skt6)
    }
    
    func saveSKT7Results() {
        self.skt7.finished = true
    }
    
    func saveSKT8Results(rememberedSymbolNames: [String]) {
        self.skt8.finished = true
        self.skt8.rememberedSymbolNames = rememberedSymbolNames
        
        try! saveToJson(name: "skt8", data: self.skt8)
        
    }
    
    func saveSKT9Results(correctlyRememberedSymbolNames: [String]) {
        self.skt9.finished = true
        self.skt9.correctlyRememberedSymbolNames = correctlyRememberedSymbolNames
        
        try! saveToJson(name: "skt9", data: self.skt9)
    }
    
    // VFT
    func saveVFTResults(recognizedAnimalNames: [String]) {
        self.vft.finished = true
        self.vft.recognizedAnimalNames = recognizedAnimalNames
        
        try! saveToJson(name: "vft", data: self.vft)
    }
    // BNT
    func saveBNTResults(recognizedObjectNames: [String]) {
        self.bnt.finished = true
        self.bnt.recognizedObjectNames = recognizedObjectNames
        
        try! saveToJson(name: "bnt", data: self.bnt)
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
    
    func saveToJson(name: String, data: Codable) throws {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uuidDirectory = documentsDirectory.appendingPathComponent(uuid)  // UUID directory
        let testDirectory = uuidDirectory.appendingPathComponent(name)        // Test-specific directory

        // Create the UUID directory if it does not exist
        if !fileManager.fileExists(atPath: uuidDirectory.path) {
            try fileManager.createDirectory(at: uuidDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        // Create the test-specific directory if it does not exist
        if !fileManager.fileExists(atPath: testDirectory.path) {
            try fileManager.createDirectory(at: testDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        let jsonData = try JSONEncoder().encode(data)
        let jsonFileUrl = testDirectory.appendingPathComponent("\(name).json")
        try jsonData.write(to: jsonFileUrl)
    }

}
