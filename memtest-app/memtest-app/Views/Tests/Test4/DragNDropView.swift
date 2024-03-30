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
    var circleNode: SKShapeNode!
    var isDraggingCircleNode = false
    let rows = 4
    let columns = 5
    let spacing: CGFloat = 10

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if self.size.width > 0 && self.size.height > 0 {
            setupScene() // Re-setup the scene to adjust for new size
        }
    }
    
    func setupScene() {
        self.backgroundColor = .white
        self.removeAllChildren() // Clear existing nodes

        // Determine sizes based on the current scene size
        let targetSize = min(self.size.width, self.size.height) / CGFloat(max(rows, columns)) - spacing
        let totalWidth = CGFloat(columns) * (targetSize + spacing) - spacing
        let totalHeight = CGFloat(rows) * (targetSize + spacing) - spacing

        let startX = -totalWidth / 2 + targetSize / 2
        let startY = totalHeight / 2 - targetSize / 2

        // Create rows and columns of gray circles centered in the middle
        for row in 0..<rows {
            for column in 0..<columns {
                let circleNode = SKShapeNode(circleOfRadius: targetSize / 2.1)
                circleNode.fillColor = .gray
                let xPosition = startX + CGFloat(column) * (targetSize + spacing)
                let yPosition = startY - CGFloat(row) * (targetSize + spacing)
                circleNode.position = CGPoint(x: xPosition, y: yPosition)
                circleNode.name = "grayCircle\(row)\(column)" // Assign a unique name
                self.addChild(circleNode)
            }
        }

        // Setup or adjust the draggable blue circle
        if circleNode == nil {
            circleNode = SKShapeNode(circleOfRadius: targetSize / 4) // Smaller circle for dragging
            circleNode.fillColor = .blue
        } else {
            circleNode.path = CGPath(ellipseIn: CGRect(x: -targetSize / 4, y: -targetSize / 4, width: targetSize / 2, height: targetSize / 2), transform: nil)
        }
        circleNode.position = CGPoint(x: 0, y: 0) // Start in center
        self.addChild(circleNode)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        // Check if the circle was touched
        if circleNode.contains(pos) {
            isDraggingCircleNode = true
            circleNode.position = pos
        }
    }

    func touchMoved(toPoint pos : CGPoint) {
        // Move the circle if dragging
        if isDraggingCircleNode {
            circleNode.position = pos
        }
    }

    func touchUp(atPoint pos : CGPoint) {
        // Reset dragging state
        isDraggingCircleNode = false
        
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        var nearestCircleNode: SKShapeNode?

        // Find the nearest gray circle
        self.children.forEach { node in
            if node.name?.contains("grayCircle") == true {
                let distance = hypot(node.position.x - circleNode.position.x, node.position.y - circleNode.position.y)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestCircleNode = node as? SKShapeNode
                }
            }
        }

        // Snap to the nearest gray circle
        if let nearestCircle = nearestCircleNode {
            circleNode.position = nearestCircle.position
        }
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
        isDraggingCircleNode = false // Reset dragging state
    }
}
