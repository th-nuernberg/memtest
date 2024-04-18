//
//  AnimalNameChecker.swift
//  memtest-app
//
//  Created by Christopher Witzl on 18.04.24.
//

import Foundation


class AnimalNameChecker {
    var words: [String] = []
    
    init() {
        loadWordsFromFile()
    }
    
    private func loadWordsFromFile() {
        // Angenommen, die Datei heißt "words.txt" und befindet sich im Hauptbundle
        if let filepath = Bundle.main.path(forResource: "animal_names_german", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                words = contents.components(separatedBy: .newlines) // Trennt den String in Zeilen
            } catch {
                // Fehlerbehandlung, falls die Datei nicht gelesen werden kann
                print("Fehler beim Lesen der Datei: \(error)")
            }
        } else {
            print("Datei nicht gefunden!")
        }
    }
    
    func checkWord(_ word: String) -> Bool {
        return words.contains(word)
    }
}
