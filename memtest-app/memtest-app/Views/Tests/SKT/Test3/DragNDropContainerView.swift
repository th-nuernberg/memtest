//
//  DragNDropContainerView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 30.04.24.
//

import SwiftUI
import SpriteKit

struct DragElement: Equatable {
    var posIndex: Int;
    var label: String?
    var color: UIColor
}

struct DropZone {
    var label: String?
}

struct DragNDropContainerView: UIViewRepresentable {
    // Input Params
    var dragElements: [DragElement]
    var dropZones: [DropZone]
    var columns = 5
    var isDragEnabled: Bool = true
    // Callback TODO: instead of [(number, position)] it should be sorted [DragElement] with according indices
    var onPositionsChanged: ([DragElement]) -> Void
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene == nil {
            let scene = DragNDropScene(size: uiView.bounds.size, dragElements: dragElements, dropZones: dropZones, columns: columns, isDragEnabled: isDragEnabled, onPositionsChanged: onPositionsChanged)
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            uiView.presentScene(scene)
        } else {
            uiView.scene?.size = uiView.bounds.size
        }
    }
}

class DragNDropScene: SKScene {
    // For the setup
    private var dropZones: [DropZone]
    private var dragElements: [DragElement]
    private var isDragEnabled: Bool
    // For the layout
    private var columns: Int
    private let spacing: CGFloat = 10
    // For the active displaying
    var dropZonePositions: [CGPoint] = []
    var draggableElementPositions: [CGPoint] = []
    // For dragging
    var currentlyDraggedNode: SKShapeNode?
    var originalPositionOfDraggedNode: CGPoint?
    // Callback
    var onPositionsChanged: ([DragElement]) -> Void
    
    init(size: CGSize, dragElements: [DragElement], dropZones: [DropZone], columns: Int, isDragEnabled: Bool, onPositionsChanged: @escaping ([DragElement]) -> Void) {
        self.dropZones = dropZones
        self.dragElements = dragElements
        self.isDragEnabled = isDragEnabled
        self.columns = columns
        // Callback
        self.onPositionsChanged = onPositionsChanged
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Called when the scene is loaded
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        //reportDropZoneIndices()
    }
    
    // sets and or updates the scene if the view size changed
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if self.size.width > 0 && self.size.height > 0 && oldSize != self.size {
            setupScene()
        }
    }
    
    // this functions generates all objects => circles and dropzones
    func setupScene() {
        guard self.size.width > 0 && self.size.height > 0 else {
            print("Scene size is not valid yet.")
            return
        }

        self.backgroundColor = .white
        self.removeAllChildren()

        configureDropZonesAndAddDragElements()
    }
    
    private func configureDropZonesAndAddDragElements() {
        let targetSize = min(self.size.width, self.size.height) / CGFloat(columns) - spacing
        let (startX, startY) = calculateStartPositions(targetSize: targetSize)
    
        // Create DropZones and Add DragElements
        createDropZones(startX: startX, startY: startY, targetSize: targetSize)
        createDragElements(targetSize: targetSize)
    }
    
    private func calculateStartPositions(targetSize: CGFloat) -> (CGFloat, CGFloat) {
        let totalWidth = CGFloat(columns) * (targetSize + spacing) - spacing
        let startX = -totalWidth / 2 + targetSize / 2
        let startY = (self.size.height / 2) - targetSize - spacing
        return (startX, startY)
    }
    
    private func createDropZones(startX: CGFloat, startY: CGFloat, targetSize: CGFloat) {
        var dropZoneIndex = 0
        for row in 0..<Int(self.dropZones.count/self.columns) {
            for column in 0..<columns {
                createDropZone(dropZoneIndex: dropZoneIndex, row: row, column: column, startX: startX, startY: startY, targetSize: targetSize)
                dropZoneIndex = dropZoneIndex + 1
            }
        }
    }
    
    private func createDropZone(dropZoneIndex: Int, row: Int, column: Int, startX: CGFloat, startY: CGFloat, targetSize: CGFloat) {
        let xPosition = startX + CGFloat(column) * (targetSize + spacing)
        let yPosition = startY - CGFloat(row) * (targetSize + spacing)
        let position = CGPoint(x: xPosition, y: yPosition)

        
        let dropZoneNode = createDropZoneNode(dropZoneIndex: dropZoneIndex, position: position, targetSize: targetSize)
        self.addChild(dropZoneNode)

        // for the shadow effect
        let shadowNode = createShadowNode(position: position, targetSize: targetSize)
        self.addChild(shadowNode)

        dropZonePositions.append(position)
        
        let indicesToAddDragElement = self.dragElements.map({ dragElement in
            return dragElement.posIndex
        })
        
        if indicesToAddDragElement.contains(dropZoneIndex) {
            draggableElementPositions.append(dropZoneNode.position)
        }
    }
    private func createDropZoneNode(dropZoneIndex: Int, position: CGPoint, targetSize: CGFloat) -> SKShapeNode {
        let dropZoneNode = SKShapeNode(circleOfRadius: targetSize / 2.1)
        dropZoneNode.fillColor = UIColor(Color(hex: "#D9D9D9"))
        dropZoneNode.position = position
        dropZoneNode.name = "dropZone\(dropZoneIndex)"
        
        if (self.dropZones[dropZoneIndex].label != nil){
            dropZoneNode.addChild(createLabelNode(label: self.dropZones[dropZoneIndex].label!))
        }
        
        return dropZoneNode
    }
    
    private func createLabelNode(label: String) -> SKLabelNode {
        let label = SKLabelNode(text: "\(label)")
        label.fontName = "SFProText-SemiBold"
        label.fontColor = .black
        label.fontSize = 40
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
    
    private func createShadowNode(position: CGPoint, targetSize: CGFloat) -> SKShapeNode {
        let shadowNode = SKShapeNode(circleOfRadius: targetSize / 2.1)
        shadowNode.fillColor = UIColor.black.withAlphaComponent(0.5)
        shadowNode.position = CGPoint(x: position.x, y: position.y - 3)
        shadowNode.zPosition = -1
        return shadowNode
    }
    
    private func createDragElements(targetSize: CGFloat) {
        for (index, dragElement) in dragElements.enumerated() {
            let circleNode = createDragElement(dragElement: dragElement, index: index, targetSize: targetSize)
            self.addChild(circleNode)
        }
    }
    
    private func createDragElement(dragElement: DragElement, index: Int, targetSize: CGFloat) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: targetSize / 2.1)
        circle.fillColor = dragElement.color
        circle.strokeColor = dragElement.color
        circle.position = draggableElementPositions[index]
        circle.zPosition = 1
        circle.name = "dragNode\(dragElement.label ?? "")"
        
        let label = createLabelNode(label: dragElement.label ?? "")
        circle.addChild(label)
        
        return circle
    }
    
    // MARK: all gesture stuff
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragEnabled, let touch = touches.first else { return }
        
        let pos = touch.location(in: self)
        self.children.forEach { node in
            if let dragNode = node as? SKShapeNode, dragNode.name?.starts(with: "dragNode") ?? false, dragNode.contains(pos) {
                currentlyDraggedNode = dragNode
                originalPositionOfDraggedNode = dragNode.position
                dragNode.zPosition = 10
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragEnabled, let touch = touches.first, let draggedNode = currentlyDraggedNode else { return }
        let pos = touch.location(in: self)
        draggedNode.position = pos
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragEnabled, let draggedNode = currentlyDraggedNode, let originalPosition = originalPositionOfDraggedNode else { return }
        
        if let dropZone = findNearestDropZone(for: draggedNode) {
            resolvePositionConflicts(for: draggedNode, withDropZone: dropZone, originalPosition: originalPosition)
        }
        
        finalizeDragOperation(for: draggedNode)
        reportDropZoneIndices()
    }
    
    private func findNearestDropZone(for circle: SKShapeNode) -> SKShapeNode? {
        let potentialDropZones = self.children.compactMap { $0 as? SKShapeNode }.filter { $0.name?.contains("dropZone") == true }
        
        let sortedDropZones = potentialDropZones.sorted {
            hypot($0.position.x - circle.position.x, $0.position.y - circle.position.y) <
            hypot($1.position.x - circle.position.x, $1.position.y - circle.position.y)
        }
        
        return sortedDropZones.first
    }
    
    private func resolvePositionConflicts(for circle: SKShapeNode, withDropZone dropZone: SKShapeNode, originalPosition: CGPoint) {
        let occupyingCircle = self.children.compactMap { $0 as? SKShapeNode }.first(where: { otherCircle in
            otherCircle != circle &&
            otherCircle.name?.starts(with: "dragNode") ?? false &&
            dropZone.position == otherCircle.position
        })
        
        if let occupyingCircle = occupyingCircle {
            // swaps the positions
            occupyingCircle.position = originalPosition
        }
        circle.position = dropZone.position
    }
    
    private func finalizeDragOperation(for circle: SKShapeNode) {
        circle.zPosition = 1
        currentlyDraggedNode = nil
        originalPositionOfDraggedNode = nil
    }
    
    // reports the current indices of the numberCircles
    func reportDropZoneIndices() {
        var updatedDragElements: [DragElement] = []

        self.children.forEach { node in
            if let dragNode = node as? SKShapeNode,
               let name = dragNode.name,
               name.starts(with: "dragNode"),
               let dropZoneIndex = determineClosestDropZoneIndex(for: dragNode) {
                
                let number = name.replacingOccurrences(of: "dragNode", with: "")
                // This is never reached
                if let index = self.dragElements.firstIndex(where: { $0.label == number }) {
                    let updatedElement = DragElement(posIndex: dropZoneIndex, label: number, color: dragNode.fillColor)
                    updatedDragElements.append(updatedElement)
                }
            }
        }

        // Ensure all elements are returned, including those not updated
        for element in dragElements {
            if !updatedDragElements.contains(where: { $0.label == element.label }) {
                updatedDragElements.append(element)
            }
        }

        updatedDragElements.sort(by: { $0.posIndex < $1.posIndex })
        onPositionsChanged(updatedDragElements)
    }
    
    private func determineClosestDropZoneIndex(for circle: SKShapeNode) -> Int? {
        let distances = dropZonePositions.enumerated().map { (index, dropZonePosition) in
            return (index: index, distance: hypot(dropZonePosition.x - circle.position.x, dropZonePosition.y - circle.position.y))
        }
        
        guard let closest = distances.min(by: { $0.distance < $1.distance }) else { return nil }
        return closest.index
    }
}

