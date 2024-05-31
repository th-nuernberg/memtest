//
//  Results.swift
//  memtest-app
//
//  Created by Christopher Witzl on 30.05.24.
//

import Foundation

struct VFTResults {
    var finished = false
    private var recognizedAnimalNames: [String] = []
}

struct BNTResults {
    var finished = false
    private var recognizedObjectNames: [String] = []
}

struct PDTResults {
    var finished = false
}

struct SKTResults {
    
    var skt1Results = SKT1Results()
    var skt2Results = SKT1Results()
    var skt3Results = SKT1Results()
    var skt4Results = SKT1Results()
    var skt5Results = SKT1Results()
    var skt6Results = SKT1Results()
    var skt7Results = SKT1Results()
    var skt8Results = SKT1Results()
    var skt9Results = SKT9Results()
    
}



struct SKT1Results {
    var finished = false
    var recognizedSymbolNames: [String] = []
}

struct SKT2Results {
    var finished = false
    var rememberedSymbolNames: [String] = []
}

struct SKT3Results {
    var finished = false
}

struct SKT4Results {
    var finished = false
    var dragElements: [DragElement]
}

struct SKT5Results {
    var finished = false
    var dragElements: [DragElement]
}

struct SKT6Results {
    var finished = false
    var symbolCounts: [String: Int] = ["★": 0, "✻": 0, "▢": 0]
    var symbolToCount: String = ""
    var symbolField: [String] = []
    var taps: [(Int, String)] = []
    var userSymbolCount: Int = 0
}

struct SKT7Results {
    var finished = false
}

struct SKT8Results {
    var finished = false
    var rememberedSymbolNames: [String] = []
}

struct SKT9Results {
    var finished = false
    var correctlyRememberedSymbolNames: [String] = []
}
