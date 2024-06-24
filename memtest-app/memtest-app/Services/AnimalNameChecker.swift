//
//  AnimalNameChecker.swift
//  memtest-app
//
//  Created by Christopher Witzl on 18.04.24.
//
// TODO: use germanet for animal names

import Foundation

class TreeNode {
    var children: [Character: TreeNode] = [:]
    var isWord: Bool = false
    
    func insert(word: String) {
        guard !word.isEmpty else { return }
        var current = self
        for letter in word.lowercased() {
            if current.children[letter] == nil {
                current.children[letter] = TreeNode()
            }
            current = current.children[letter]!
        }
        current.isWord = true
    }
    
    func search(_ word: String) -> Bool {
        var current = self
        for letter in word.lowercased() {
            guard let nextNode = current.children[letter] else { return false }
            current = nextNode
        }
        return current.isWord
    }
}

class AnimalNameChecker {
    var tree = TreeNode()
    
    init() {
        loadWordsFromFile()
    }
    
    private func loadWordsFromFile() {
        if let filepath = Bundle.main.path(forResource: "animal_names_german", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let words = contents.components(separatedBy: .newlines)
                for word in words where !word.isEmpty {
                    tree.insert(word: word)
                }
            } catch {
                // Error handling if the file cannot be read
                print("Error reading the file: \(error)")
            }
        } else {
            print("File not found!")
        }
    }
    
    func checkWord(_ word: String) -> Bool {
        return tree.search(word)
    }
}
