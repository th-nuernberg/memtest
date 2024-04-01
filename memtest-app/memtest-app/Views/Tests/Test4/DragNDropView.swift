//
//  DragNDropView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 26.03.24.
//

import SpriteKit
import SwiftUI

struct OrderNumberSceneContainerView: UIViewRepresentable {
    var numberCircles: [NumberCircles]
    var onPositionsChanged: ([(Int, Int)]) -> Void
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene == nil {
            let scene = OrderNumberScene(size: uiView.bounds.size, numberCircles: numberCircles, onPositionsChanged: onPositionsChanged)
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            uiView.presentScene(scene)
        } else {
            uiView.scene?.size = uiView.bounds.size
        }
    }
}

class OrderNumberScene: SKScene {
    var onPositionsChanged: ([(Int, Int)]) -> Void
    var numberCircles: [NumberCircles]
    var draggableCircles: [SKShapeNode] = []
    var dropZonePositions: [CGPoint] = []
    var draggableCircleStartingPositions: [CGPoint] = []
    var currentlyDraggingCircleNode: SKShapeNode?
    var originalPositionOfDraggingCircle: CGPoint?
    let rows = 4
    let columns = 5
    let spacing: CGFloat = 10

    init(size: CGSize, numberCircles: [NumberCircles], onPositionsChanged: @escaping ([(Int, Int)]) -> Void) {
        self.onPositionsChanged = onPositionsChanged
        self.numberCircles = numberCircles
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Called when the scene is loaded
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        reportDropZoneIndices()
    }
    
    // reports the current indices of the numberCircles
    func reportDropZoneIndices() {
        var occupancyReport: [(Int, Int)] = []  // (Number, DropZoneIndex)
        
        self.children.forEach { node in
            if let circleNode = node as? SKShapeNode,
               let name = circleNode.name,
               name.starts(with: "circle"),
               let number = Int(name.replacingOccurrences(of: "circle", with: "")),
               let dropZoneIndex = determineClosestDropZoneIndex(for: circleNode) {
               
                occupancyReport.append((number, dropZoneIndex))
            }
        }

        occupancyReport.sort(by: { $0.1 < $1.1 })
        onPositionsChanged(occupancyReport)
    }
    
    private func determineClosestDropZoneIndex(for circle: SKShapeNode) -> Int? {
        let distances = dropZonePositions.enumerated().map { (index, dropZonePosition) in
            return (index: index, distance: hypot(dropZonePosition.x - circle.position.x, dropZonePosition.y - circle.position.y))
        }
        
        guard let closest = distances.min(by: { $0.distance < $1.distance }) else { return nil }
        return closest.index
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

        configureDropZonesAndDraggableCircles()
    }

    private func configureDropZonesAndDraggableCircles() {
        let targetSize = calculateTargetSize()
        let (startX, startY) = calculateStartPositions(targetSize: targetSize)

        createDropZones(startX: startX, startY: startY, targetSize: targetSize)
        createDraggableCircles(targetSize: targetSize)
    }

    private func calculateTargetSize() -> CGFloat {
        return min(self.size.width, self.size.height) / CGFloat(max(rows, columns)) - spacing
    }

    private func calculateStartPositions(targetSize: CGFloat) -> (CGFloat, CGFloat) {
        let totalWidth = CGFloat(columns) * (targetSize + spacing) - spacing
        let startX = -totalWidth / 2 + targetSize / 2
        let startY = (self.size.height / 2) - targetSize - spacing
        return (startX, startY)
    }

    private func createDropZones(startX: CGFloat, startY: CGFloat, targetSize: CGFloat) {
        for row in 0..<rows {
            for column in 0..<columns {
                createDropZone(row: row, column: column, startX: startX, startY: startY, targetSize: targetSize)
            }
        }
    }

    private func createDropZone(row: Int, column: Int, startX: CGFloat, startY: CGFloat, targetSize: CGFloat) {
        let xPosition = startX + CGFloat(column) * (targetSize + spacing)
        let yPosition = startY - CGFloat(row) * (targetSize + spacing)
        let position = CGPoint(x: xPosition, y: yPosition)

        let dropZoneNode = SKShapeNode(circleOfRadius: targetSize / 2.1)
        dropZoneNode.fillColor = UIColor(Color(hex: "#D9D9D9"))
        dropZoneNode.position = position
        dropZoneNode.name = "grayCircle\(row)\(column)"
        self.addChild(dropZoneNode)

        // for the shadow effect
        let shadowNode = createShadowNode(position: position, targetSize: targetSize)
        self.addChild(shadowNode)

        dropZonePositions.append(position)
        
        // only sets the circles in the last 2 rows
        if row == 2 || row == 3 {
            draggableCircleStartingPositions.append(dropZoneNode.position)
        }
    }

    private func createShadowNode(position: CGPoint, targetSize: CGFloat) -> SKShapeNode {
        let shadowNode = SKShapeNode(circleOfRadius: targetSize / 2.1)
        shadowNode.fillColor = UIColor.black.withAlphaComponent(0.5)
        shadowNode.position = CGPoint(x: position.x, y: position.y - 3)
        shadowNode.zPosition = -1
        return shadowNode
    }

    private func createDraggableCircles(targetSize: CGFloat) {
        if draggableCircleStartingPositions.count < numberCircles.count {
            fatalError("Not enough positions for numberCircles. Expected \(numberCircles.count), got \(draggableCircleStartingPositions.count).")
        }

        for (index, numberCircle) in numberCircles.enumerated() {
            let circleNode = createDraggableCircle(numberCircle: numberCircle, index: index, targetSize: targetSize)
            self.addChild(circleNode)
        }
    }

    private func createDraggableCircle(numberCircle: NumberCircles, index: Int, targetSize: CGFloat) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: targetSize / 2.1)
        circle.fillColor = numberCircle.color
        circle.strokeColor = numberCircle.color
        circle.position = draggableCircleStartingPositions[index]
        circle.zPosition = 1
        circle.name = "circle\(numberCircle.number)"
        
        let label = createCircleLabel(number: numberCircle.number)
        circle.addChild(label)
        
        return circle
    }

    private func createCircleLabel(number: Int) -> SKLabelNode {
        let label = SKLabelNode(text: "\(number)")
        label.fontName = "SFProText-SemiBold"
        label.fontColor = .black
        label.fontSize = 40
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }

    func touchDown(atPoint pos: CGPoint) {
        for blueCircle in draggableCircles {
            if blueCircle.contains(pos) {
                currentlyDraggingCircleNode = blueCircle
                blueCircle.position = pos
                break
            }
        }
    }

    func touchMoved(toPoint pos: CGPoint) {
        if let draggingCircle = currentlyDraggingCircleNode {
            draggingCircle.position = pos
        }
    }

    func touchUp(atPoint pos: CGPoint) {
        if let draggingCircle = currentlyDraggingCircleNode {
            var nearestDistance = CGFloat.greatestFiniteMagnitude
            var nearestCircleNode: SKShapeNode?

            self.children.forEach { node in
                if let grayCircle = node as? SKShapeNode, grayCircle.name?.contains("grayCircle") == true {
                    let distance = hypot(grayCircle.position.x - draggingCircle.position.x, grayCircle.position.y - draggingCircle.position.y)
                    if distance < nearestDistance {
                        nearestDistance = distance
                        nearestCircleNode = grayCircle
                    }
                }
            }

            if let nearestCircle = nearestCircleNode {
                draggingCircle.position = nearestCircle.position
            }
        }

        currentlyDraggingCircleNode = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)

            self.children.forEach { node in
                if let circleNode = node as? SKShapeNode, circleNode.name?.starts(with: "circle") ?? false, circleNode.contains(pos) {
                    currentlyDraggingCircleNode = circleNode
                    originalPositionOfDraggingCircle = circleNode.position
                    circleNode.zPosition = 10
                    return
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggingCircle = currentlyDraggingCircleNode else { return }
        let pos = touch.location(in: self)
        draggingCircle.position = pos
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let draggingCircle = currentlyDraggingCircleNode, let originalPosition = originalPositionOfDraggingCircle else { return }
        
        if let dropZone = findNearestDropZone(for: draggingCircle) {
            resolvePositionConflicts(for: draggingCircle, withDropZone: dropZone, originalPosition: originalPosition)
        }
        
        finalizeDragOperation(for: draggingCircle)
        reportDropZoneIndices()
    }

    private func findNearestDropZone(for circle: SKShapeNode) -> SKShapeNode? {
        let potentialDropZones = self.children.compactMap { $0 as? SKShapeNode }.filter { $0.name?.contains("grayCircle") == true }
        
        let sortedDropZones = potentialDropZones.sorted {
            hypot($0.position.x - circle.position.x, $0.position.y - circle.position.y) <
            hypot($1.position.x - circle.position.x, $1.position.y - circle.position.y)
        }
        
        return sortedDropZones.first
    }

    private func resolvePositionConflicts(for circle: SKShapeNode, withDropZone dropZone: SKShapeNode, originalPosition: CGPoint) {
        let occupyingCircle = self.children.compactMap { $0 as? SKShapeNode }.first(where: { otherCircle in
            otherCircle != circle &&
            otherCircle.name?.starts(with: "circle") ?? false &&
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
        currentlyDraggingCircleNode = nil
        originalPositionOfDraggingCircle = nil
    }


    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentlyDraggingCircleNode?.zPosition = 1
        currentlyDraggingCircleNode = nil
    }

}
