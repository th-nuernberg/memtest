//
//  DragNDropView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 26.03.24.
//

import SpriteKit
import SwiftUI

struct OrderNumberSceneContainerView: UIViewRepresentable {
    
    // Create the SKView without a scene initially
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = false
        return view
    }
    
    // Once the view size is determined, update the scene's size
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene == nil {
            let scene = OrderNumberScene(size: uiView.bounds.size) // Make sure this matches the view's size
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Center the anchor point
            uiView.presentScene(scene)
        } else {
            // Ensure the scene's size is updated if the view's bounds change
            uiView.scene?.size = uiView.bounds.size
        }
    }
}

class OrderNumberScene: SKScene {
    var blueCircles: [SKShapeNode] = []
    var blueCircleStartingPositions: [CGPoint] = []
    var currentlyDraggingCircleNode: SKShapeNode?
    let rows = 4
    let columns = 5
    let spacing: CGFloat = 10

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
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
                grayCircleNode.fillColor = .gray
                let xPosition = startX + CGFloat(column) * (targetSize + spacing)
                let yPosition = startY - CGFloat(row) * (targetSize + spacing)
                grayCircleNode.position = CGPoint(x: xPosition, y: yPosition)
                grayCircleNode.name = "grayCircle\(row)\(column)"
                self.addChild(grayCircleNode)
                
                // Store the position of the last row of gray circles
                if row == 2 || row == 3{
                    blueCircleStartingPositions.append(grayCircleNode.position)
                }
            }
        }
        
        // Make sure you have at least 10 positions
        if blueCircleStartingPositions.count < 10 {
            fatalError("Not enough positions for blue circles. Expected 10, got \(blueCircleStartingPositions.count).")
        }

        // Now create ten blue circles using the stored positions
        for i in 0..<10 {
            let startPosition = blueCircleStartingPositions[i]
            let blueCircle = SKShapeNode(circleOfRadius: targetSize / 4)
            blueCircle.fillColor = .blue
            blueCircle.position = startPosition
            blueCircle.zPosition = 1 // Ensure blue circles are on top
            self.addChild(blueCircle)
            blueCircles.append(blueCircle)
        }
    }

    
    
    func touchDown(atPoint pos: CGPoint) {
            // Check if any blue circle was touched and set it as currently dragging
            for blueCircle in blueCircles {
                if blueCircle.contains(pos) {
                    currentlyDraggingCircleNode = blueCircle
                    blueCircle.position = pos
                    break // Exit the loop after finding the touched circle
                }
            }
        }

        func touchMoved(toPoint pos: CGPoint) {
            // Move the circle that's being dragged
            if let draggingCircle = currentlyDraggingCircleNode {
                draggingCircle.position = pos
            }
        }

        func touchUp(atPoint pos: CGPoint) {
            // Snap the circle to the nearest gray circle if one is being dragged
            if let draggingCircle = currentlyDraggingCircleNode {
                var nearestDistance = CGFloat.greatestFiniteMagnitude
                var nearestCircleNode: SKShapeNode?

                // Find the nearest gray circle
                self.children.forEach { node in
                    if let grayCircle = node as? SKShapeNode, grayCircle.name?.contains("grayCircle") == true {
                        let distance = hypot(grayCircle.position.x - draggingCircle.position.x, grayCircle.position.y - draggingCircle.position.y)
                        if distance < nearestDistance {
                            nearestDistance = distance
                            nearestCircleNode = grayCircle
                        }
                    }
                }

                // Snap to the nearest gray circle
                if let nearestCircle = nearestCircleNode {
                    draggingCircle.position = nearestCircle.position
                }
            }

            // Reset dragging state
            currentlyDraggingCircleNode = nil
        }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            touchDown(atPoint: pos)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            touchMoved(toPoint: pos)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            touchUp(atPoint: pos)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentlyDraggingCircleNode = nil
    }
}
