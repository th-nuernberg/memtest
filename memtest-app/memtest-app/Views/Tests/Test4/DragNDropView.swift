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
    var blueCircles: [SKShapeNode] = []
    var dropZonePositions: [CGPoint] = []
    var blueCircleStartingPositions: [CGPoint] = []
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
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        reportDropZoneIndices()
    }
    
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
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if self.size.width > 0 && self.size.height > 0 && oldSize != self.size {
            setupScene()
        }
    }
    
    func setupScene() {
        guard self.size.width > 0 && self.size.height > 0 else {
            print("Scene size is not valid yet.")
            return
        }
        
        self.backgroundColor = .white
        self.removeAllChildren() // Clear existing nodes

        let targetSize = min(self.size.width, self.size.height) / CGFloat(max(rows, columns)) - spacing
        let totalWidth = CGFloat(columns) * (targetSize + spacing) - spacing

        let startX = -totalWidth / 2 + targetSize / 2
        let startY = (self.size.height / 2) - targetSize - spacing

        // Create rows and columns of gray circles
        for row in 0..<rows {
            for column in 0..<columns {
                let grayCircleNode = SKShapeNode(circleOfRadius: targetSize / 2.1)
                grayCircleNode.fillColor = UIColor(Color(hex: "#D9D9D9"))
                let xPosition = startX + CGFloat(column) * (targetSize + spacing)
                let yPosition = startY - CGFloat(row) * (targetSize + spacing)
                grayCircleNode.position = CGPoint(x: xPosition, y: yPosition)
                grayCircleNode.name = "grayCircle\(row)\(column)"
                
                
                let shadowNode = SKShapeNode(circleOfRadius: targetSize / 2.1)
                shadowNode.fillColor = UIColor.black.withAlphaComponent(0.5) // Adjust shadow color and alpha as needed
                shadowNode.position = CGPoint(x: grayCircleNode.position.x, y: grayCircleNode.position.y - 3)
                shadowNode.zPosition = grayCircleNode.zPosition - 1  // Ensure shadow is below the circle

                // Add nodes to the scene
                self.addChild(shadowNode)
                
                self.addChild(grayCircleNode)
                
                dropZonePositions.append(CGPoint(x: xPosition, y: yPosition))
                
                if row == 2 || row == 3{
                    blueCircleStartingPositions.append(grayCircleNode.position)
                }
            }
        }
        
        if blueCircleStartingPositions.count < numberCircles.count {
            fatalError("Not enough positions for blue circles. Expected \(numberCircles.count), got \(blueCircleStartingPositions.count).")
        }

        for (index, numberCircle) in numberCircles.enumerated() {
            let circle = SKShapeNode(circleOfRadius: 50) // Set your desired radius
            circle.fillColor = numberCircle.color
            circle.strokeColor = numberCircle.color
            circle.position = blueCircleStartingPositions[index]
            circle.zPosition = 1
            circle.name = "circle\(numberCircle.number)"
            
            let label = SKLabelNode(text: "\(numberCircle.number)")
            label.fontName = "SFProText-SemiBold"
            label.fontColor = .black
            label.fontSize = 40
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            
            circle.addChild(label)
            self.addChild(circle)
        }
    }

    
    
    func touchDown(atPoint pos: CGPoint) {
            for blueCircle in blueCircles {
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
        
        let potentialDropZones = self.children.compactMap { $0 as? SKShapeNode }.filter { $0.name?.contains("grayCircle") == true }
        
        let sortedDropZones = potentialDropZones.sorted {
            let distance1 = hypot($0.position.x - draggingCircle.position.x, $0.position.y - draggingCircle.position.y)
            let distance2 = hypot($1.position.x - draggingCircle.position.x, $1.position.y - draggingCircle.position.y)
            return distance1 < distance2
        }
        
        for dropZone in sortedDropZones {
            let occupyingCircle = self.children.compactMap { $0 as? SKShapeNode }.first(where: { otherCircle in
                otherCircle != draggingCircle &&
                otherCircle.name?.starts(with: "circle") ?? false &&
                dropZone.position == otherCircle.position
            })
            
            if let occupyingCircle = occupyingCircle {
                // Swap the positions
                occupyingCircle.position = originalPosition
                draggingCircle.position = dropZone.position
                break
            } else {
                draggingCircle.position = dropZone.position
                break
            }
        }
        
        draggingCircle.zPosition = 1
        currentlyDraggingCircleNode = nil
        originalPositionOfDraggingCircle = nil
            
        reportDropZoneIndices()
    }



    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentlyDraggingCircleNode?.zPosition = 1
        currentlyDraggingCircleNode = nil
    }

}
