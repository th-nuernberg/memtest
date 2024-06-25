//
//  OrderNumberTestService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 01.05.24.
//

import Foundation
import SwiftUI

// This service is designed to save the positions of the circles between SKT3 (ordering numbers) and SKT4 (putting numbers back).
class OrderNumberTestService {
    static let shared = OrderNumberTestService()
    private var dragElements: [DragElement]
    
    static let defaultDragElements: [DragElement] = [
        DragElement(posIndex: 10, label: "10", color: UIColor(Color(hex: "#D10B0B"))),
        DragElement(posIndex: 11, label: "81", color: UIColor(Color(hex: "#44FF57"))),
        DragElement(posIndex: 12, label: "72", color: UIColor(Color(hex: "#32FFE6"))),
        DragElement(posIndex: 13, label: "95", color: UIColor(Color(hex: "#9E70FF"))),
        DragElement(posIndex: 14, label: "84", color: UIColor(Color(hex: "#BCE225"))),
        DragElement(posIndex: 15, label: "73", color: UIColor(Color(hex: "#E78CFE"))),
        DragElement(posIndex: 16, label: "16", color: UIColor(Color(hex: "#F5762F"))),
        DragElement(posIndex: 17, label: "13", color: UIColor(Color(hex: "#4478FF"))),
        DragElement(posIndex: 18, label: "29", color: UIColor(Color(hex: "#AC9725"))),
        DragElement(posIndex: 19, label: "40", color: UIColor(Color(hex: "#2CBA76"))),
    ]
    
    private let dropZones: [DropZone] = [
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(label: "10"),
        DropZone(label: "81"),
        DropZone(label: "72"),
        DropZone(label: "95"),
        DropZone(label: "84"),
        DropZone(label: "73"),
        DropZone(label: "16"),
        DropZone(label: "13"),
        DropZone(label: "29"),
        DropZone(label: "40"),
    ]
    
    private init(dragElements: [DragElement]) {
        self.dragElements = dragElements
    }
    
    convenience init() {
        self.init(dragElements: OrderNumberTestService.defaultDragElements)
    }
    
    func getDragElements() -> [DragElement] {
        return self.dragElements
    }
    
    func setDragElements(dragElements: [DragElement]) {
        self.dragElements = dragElements
    }
    
    func getDropZones() -> [DropZone] {
        return self.dropZones
    }
}
