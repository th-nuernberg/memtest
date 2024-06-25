//
//  BNTPicture.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.04.24.
//

import Foundation

/// `BNT_Picture` represents a picture used in the BNT (Boston Naming Test) with its name, file name, and maximum Levenshtein distance allowed for recognition
///
/// - Parameters:
///   - name: The name of the picture
///   - file_name: The file name of the picture
///   - maxDistance: The maximum allowed Levenshtein distance for recognizing the picture name
class BNT_Picture: Identifiable {
    var name: String
    var file_name: String
    var maxDistance: Int
    
    init(name: String, file_name: String, maxDistance: Int) {
        self.name = name
        self.file_name = "Test11Assets/\(file_name)"
        self.maxDistance = maxDistance
    }
}

/// `BNTPictureList` manages a list of `BNT_Picture` objects
///
/// Features:
/// - Initializes with a predefined list of BNT pictures
class BNTPictureList {
    var pictures: [BNT_Picture] = []
    
    init() {
        pictures.append(BNT_Picture(name: "Baum", file_name: "1", maxDistance: 1)) // Simple, short
        pictures.append(BNT_Picture(name: "Bett", file_name: "2", maxDistance: 1)) // Simple, short
        pictures.append(BNT_Picture(name: "Pfeife", file_name: "3", maxDistance: 2)) // A bit more complex
        pictures.append(BNT_Picture(name: "Blume", file_name: "4", maxDistance: 1)) // Simple
        pictures.append(BNT_Picture(name: "Haus", file_name: "5", maxDistance: 1)) // Simple, short
        pictures.append(BNT_Picture(name: "Kajak", file_name: "6", maxDistance: 2)) // Uncommon
        pictures.append(BNT_Picture(name: "Zahnbürste", file_name: "7", maxDistance: 3)) // Longer, complex
        pictures.append(BNT_Picture(name: "Vulkan", file_name: "8", maxDistance: 2)) // Uncommon
        pictures.append(BNT_Picture(name: "Maske", file_name: "9", maxDistance: 2)) // Moderately simple
        pictures.append(BNT_Picture(name: "Kamel", file_name: "10", maxDistance: 2)) // Uncommon
        pictures.append(BNT_Picture(name: "Mundharmonika", file_name: "11", maxDistance: 3)) // Longer, complex
        pictures.append(BNT_Picture(name: "Zange", file_name: "12", maxDistance: 2)) // Slightly complex
        pictures.append(BNT_Picture(name: "Hängematte", file_name: "13", maxDistance: 3)) // Longer, compound
        pictures.append(BNT_Picture(name: "Trichter", file_name: "14", maxDistance: 2)) // Slightly uncommon
        pictures.append(BNT_Picture(name: "Dominos", file_name: "15", maxDistance: 2)) // Plural form
    }
}
