//
//  DragDropExampleScene.swift
//  memtest-app
//
//  Created by Christopher Witzl on 30.03.24.
//

import SwiftUI
import SpriteKit

/// `DragDropExampleSceneContainerView` provides an interface between SwiftUI and a SpriteKit scene for drag-and-drop calibration
///
/// - Parameters:
///   - calibrationComplete: A binding to track the completion status of the calibration
struct DragDropExampleSceneContainerView: UIViewRepresentable {
    
    @Binding var calibrationComplete: Bool
    
    // Create the SKView without a scene initially
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = false
        return view
    }
    
    // Update the SKView with the scene if not already present, or update the scene size
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene == nil {
            let scene = DragDropExampleScene(size: uiView.bounds.size)
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Center the anchor point
            uiView.presentScene(scene)
        } else {
            // update scene size on bounds change
            uiView.scene?.size = uiView.bounds.size
        }
        
        if let scene = uiView.scene as? DragDropExampleScene {
            scene.calibrationCompleteBinding = $calibrationComplete
        }
    }
}

/// `DragDropExampleScene` is a SpriteKit scene used for drag-and-drop calibration
class DragDropExampleScene: SKScene {
    var circleNode: SKShapeNode!
    var isDraggingCircleNode = false
    var startingRectangleNode: SKShapeNode!
    var targetRectangleNode: SKShapeNode!
    var arrowNode: SKShapeNode!
    var calibrationCompleteBinding: Binding<Bool>? // Optional binding to communicate completion status
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    
    // Setup the initial scene with shapes and positions
    func setupScene() {
        self.backgroundColor = .white
        self.removeAllChildren()
        
        let rectangleSize = CGSize(width: 200, height: 200)
        
        // Setup the start zone
        startingRectangleNode = SKShapeNode(rectOf: rectangleSize, cornerRadius: 10)
        startingRectangleNode.fillColor = .lightGray
        startingRectangleNode.position = CGPoint(x: -rectangleSize.width, y: 0)
        self.addChild(startingRectangleNode)
        
        // Setup the drop zone
        targetRectangleNode = SKShapeNode(rectOf: rectangleSize, cornerRadius: 10)
        targetRectangleNode.fillColor = .lightGray
        targetRectangleNode.position = CGPoint(x: rectangleSize.width, y: 0)
        targetRectangleNode.name = "targetRectangle"
        self.addChild(targetRectangleNode)
        
        // Setup the arrow between start and drop zones
        arrowNode = createArrowNode(from: startingRectangleNode.position, to: targetRectangleNode.position)
        self.addChild(arrowNode)
        
        // Setup the draggable red circle
        let circleDiameter = rectangleSize.height / 2
        circleNode = SKShapeNode(circleOfRadius: circleDiameter / 2)
        circleNode.fillColor = .red
        circleNode.position = startingRectangleNode.position
        self.addChild(circleNode)
    }
    
    // Create an arrow node to guide the user
    func createArrowNode(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: start.x + 110, y: 0))
        let arrowLength: CGFloat = end.x - start.x - 220
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength, y: 0))
        
        let arrowWidth: CGFloat = 20
        path.move(to: CGPoint(x: start.x + 110 + arrowLength, y: 0))
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength - arrowWidth, y: arrowWidth))
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength, y: 0))
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength - arrowWidth, y: -arrowWidth))
        path.close()
        
        let arrowNode = SKShapeNode(path: path.cgPath)
        arrowNode.strokeColor = .lightGray
        arrowNode.lineWidth = 8
        arrowNode.fillColor = .lightGray
        
        return arrowNode
    }
    
    // Handle touch down event
    func touchDown(atPoint pos: CGPoint) {
        if circleNode.contains(pos) {
            isDraggingCircleNode = true
            circleNode.position = pos
        }
    }
    
    // Handle touch move event
    func touchMoved(toPoint pos: CGPoint) {
        if isDraggingCircleNode {
            circleNode.position = pos
        }
    }
    
    // Handle touch up event
    func touchUp(atPoint pos: CGPoint) {
        isDraggingCircleNode = false
        
        // Snapping the circle to the target position if within bounds
        if targetRectangleNode.frame.contains(circleNode.position) {
            circleNode.position = targetRectangleNode.position
            calibrationCompleteBinding?.wrappedValue = true
        } else {
            circleNode.position = startingRectangleNode.position
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
        isDraggingCircleNode = false
    }
}
