//
//  TestSymbol.swift
//  memtest-app
//
//  Created by Christopher Witzl on 21.03.24.
//

import Foundation

class TestSymbol {
    var name: String
    var synonyms: [String]
    var fileUrl: String
    
    init(name: String, synonyms: [String], fileUrl: String) {
        self.name = name
        self.synonyms = synonyms
        self.fileUrl = fileUrl
    }
}


class TestSymbolList {
    var symbols: [TestSymbol] = []
    init() {
        symbols.append(TestSymbol(name: "Papagei", synonyms: [], fileUrl: "Test1Icons/test1_1"))
        symbols.append(TestSymbol(name: "Knopf", synonyms: [], fileUrl: "Test1Icons/test1_2"))
        symbols.append(TestSymbol(name: "Pinguin", synonyms: [], fileUrl: "Test1Icons/test1_3"))
        symbols.append(TestSymbol(name: "Tasche", synonyms: [], fileUrl: "Test1Icons/test1_4"))
        symbols.append(TestSymbol(name: "Streichholz", synonyms: [], fileUrl: "Test1Icons/test1_5"))
        symbols.append(TestSymbol(name: "Kiste", synonyms: [], fileUrl: "Test1Icons/test1_6"))
        symbols.append(TestSymbol(name: "Banane", synonyms: [], fileUrl: "Test1Icons/test1_7"))
        symbols.append(TestSymbol(name: "Eis", synonyms: [], fileUrl: "Test1Icons/test1_8"))
        symbols.append(TestSymbol(name: "Drache", synonyms: [], fileUrl: "Test1Icons/test1_9"))
        symbols.append(TestSymbol(name: "Schirm", synonyms: [], fileUrl: "Test1Icons/test1_10"))
        symbols.append(TestSymbol(name: "Schaufel", synonyms: [], fileUrl: "Test1Icons/test1_11"))
        symbols.append(TestSymbol(name: "Nagel", synonyms: [], fileUrl: "Test1Icons/test1_12"))
    }
    
    func contains(word: String) -> Bool {
        for symbol in symbols {
            if symbol.name.lowercased() == word.lowercased() || symbol.synonyms.contains(where: { $0.lowercased() == word.lowercased() }) {
                return true
            }
        }
        return false
    }
}
