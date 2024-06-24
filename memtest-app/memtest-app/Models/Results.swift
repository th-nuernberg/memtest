//
//  Results.swift
//  memtest-app
//
//  Created by Christopher Witzl on 30.05.24.
//
// The structs for the testresults
// For Future Work -> make them SwitData compatible

import Foundation

protocol TestResult: Codable {
    var finished: Bool { get set }
}

struct VFTResults: TestResult {
    var finished = false
    var recognizedAnimalNames: [String] = []
}

struct BNTResults: TestResult {
    var finished = false
    var recognizedObjectNames: [String] = []
}

struct PDTResults: TestResult {
    var finished = false
}

struct DragElementCodable: Codable {
    var posIndex: Int;
    var label: String?
    
    init(dragElement: DragElement) {
        self.posIndex = dragElement.posIndex
        self.label = dragElement.label
    }
}

struct SKT1Results: TestResult {
    var finished = false
    var recognizedSymbolNames: [String] = []
}

struct SKT2Results: TestResult {
    var finished = false
    var rememberedSymbolNames: [String] = []
}

struct SKT3Results: TestResult {
    var finished = false
}

struct SKT4Results: TestResult {
    var finished = false
    var dragElements: [DragElementCodable] = []
}

struct SKT5Results: TestResult {
    var finished = false
    var dragElements: [DragElementCodable] = []
}

struct Tap: Codable {
    var index: Int
    var label: String
}


struct SKT6Results: TestResult {
    var finished = false
    var symbolCounts: [String: Int] = ["★": 0, "✻": 0, "▢": 0]
    var symbolToCount: String = ""
    var symbolField: [String] = []
    var taps: [Tap] = []
    var userSymbolCount: Int = 0
}

struct SKT7Results: TestResult {
    var finished = false
}

struct SKT8Results: TestResult {
    var finished = false
    var rememberedSymbolNames: [String] = []
}

struct SKT9Results: TestResult {
    var finished = false
    var correctlyRememberedSymbolNames: [String] = []
}
