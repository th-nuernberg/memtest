//
//  DragDropExampleScene.swift
//  memtest-app
//
//  Created by Christopher Witzl on 30.03.24.
//


import SwiftUI
import SpriteKit

// for providing a interface between SwiftUI and SpriteKit Scene
struct DragDropExampleSceneContainerView: UIViewRepresentable {
    
    @Binding var calibrationComplete: Bool
    
    // Create the SKView without a scene initially
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = false
        return view
    }
    
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



class DragDropExampleScene: SKScene {
    var circleNode: SKShapeNode!
    var isDraggingCircleNode = false
    var startingRectangleNode: SKShapeNode!
    var targetRectangleNode: SKShapeNode!
    var arrowNode: SKShapeNode!
    var calibrationCompleteBinding: Binding<Bool>? // Optional binding to communicate completion status
    
    // initially called when the scene has been presented by a view
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    
    func setupScene() {
        self.backgroundColor = .white
        self.removeAllChildren()
        
        let rectangleSize = CGSize(width: 200, height: 200)
        
        // the start zone
        startingRectangleNode = SKShapeNode(rectOf: rectangleSize, cornerRadius: 10)
        startingRectangleNode.fillColor = .lightGray
        startingRectangleNode.position = CGPoint(x: -rectangleSize.width, y: 0)
        self.addChild(startingRectangleNode)
        
        // the drop zone
        targetRectangleNode = SKShapeNode(rectOf: rectangleSize, cornerRadius: 10)
        targetRectangleNode.fillColor = .lightGray
        targetRectangleNode.position = CGPoint(x: rectangleSize.width, y: 0)
        targetRectangleNode.name = "targetRectangle"
        self.addChild(targetRectangleNode)
        
        
        arrowNode = createArrowNode(from: startingRectangleNode.position, to: targetRectangleNode.position)
        self.addChild(arrowNode)
        
        
        // Setup the draggable red circle
        let circleDiameter = rectangleSize.height / 2
        circleNode = SKShapeNode(circleOfRadius: circleDiameter / 2)
        circleNode.fillColor = .red
        circleNode.position = startingRectangleNode.position
        self.addChild(circleNode)
    }
    
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
    
    
    func touchDown(atPoint pos : CGPoint) {
        if circleNode.contains(pos) {
            isDraggingCircleNode = true
            circleNode.position = pos
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if isDraggingCircleNode {
            circleNode.position = pos
        }
    }
    
    // handles the end of a touch drag event
    func touchUp(atPoint pos : CGPoint) {
        isDraggingCircleNode = false
        
        // snapping
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
