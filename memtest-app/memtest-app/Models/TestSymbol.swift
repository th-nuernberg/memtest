//
//  TestSymbol.swift
//  memtest-app
//
//  Created by Christopher Witzl on 21.03.24.
//

import Foundation

/// `TestSymbol` represents a symbol used in the tests with its name, synonyms, and file URL
///
/// - Parameters:
///   - name: The name of the symbol
///   - synonyms: A list of synonyms for the symbol
///   - fileUrl: The file URL for the symbol's image
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

/// `TestSymbolList` manages a list of `TestSymbol` objects
///
/// Features:
/// - Initializes with a predefined list of symbols
/// - Provides a method to check if a word is contained in the list of symbols or their synonyms
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
    
    /// Checks if a given word matches any symbol name or synonym in the list
    ///
    /// - Parameter word: The word to check
    /// - Returns: `true` if the word is a symbol name or synonym, `false` otherwise
    func contains(word: String) -> Bool {
        for symbol in symbols {
            if symbol.name.lowercased() == word.lowercased() || symbol.synonyms.contains(where: { $0.lowercased() == word.lowercased() }) {
                return true
            }
        }
        return false
    }
}
