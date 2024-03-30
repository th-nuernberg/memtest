//
//  DragDropCalibrationView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct DragDropCalibrationView: View {
    @State var showNextView: Bool = false
    @State var calibrationComplete = false
    
    var body: some View {
        VStack(spacing: 12){
            Text("Probieren sie es selbst aus")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)
                .padding(.horizontal)
            Text("Sie müssen den Kreis in das Ziel bewegen um fortfahren zu können.")
            Spacer()
            
            DragDropExampleSceneContainerView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            
        }
        
        if calibrationComplete {
            Button("Zur nächsten View", action: {
                print("Proceeding to the next view...")
            })
            .padding()
        }
    }
}


#Preview {
    DragDropCalibrationView()
}

struct DragDropExampleSceneContainerView: UIViewRepresentable {
    
    // Create the SKView without a scene initially
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = false
        return view
    }
    
    // Once the view size is determined, update the scene's size
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene == nil {
            let scene = DragDropExampleScene(size: uiView.bounds.size) // Make sure this matches the view's size
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Center the anchor point
            uiView.presentScene(scene)
        } else {
            // Ensure the scene's size is updated if the view's bounds change
            uiView.scene?.size = uiView.bounds.size
        }
    }
}


import SpriteKit

class DragDropExampleScene: SKScene {
    var circleNode: SKShapeNode!
    var isDraggingCircleNode = false
    var startingRectangleNode: SKShapeNode!
    var targetRectangleNode: SKShapeNode!
    var arrowNode: SKShapeNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    
    func setupScene() {
        self.backgroundColor = .white
        self.removeAllChildren() // Clear existing nodes
        
        let rectangleSize = CGSize(width: 200, height: 200) // Size of the rectangles
        
        // Create and position the starting rectangle on the left
        startingRectangleNode = SKShapeNode(rectOf: rectangleSize, cornerRadius: 10)
        startingRectangleNode.fillColor = .lightGray
        startingRectangleNode.position = CGPoint(x: -rectangleSize.width, y: 0)
        self.addChild(startingRectangleNode)
        
        // Create and position the target rectangle on the right
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
        circleNode.position = startingRectangleNode.position // Start inside the left rectangle
        self.addChild(circleNode)
    }
    
    func createArrowNode(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: start.x + 110, y: 0)) // Start slightly to the right of the starting rectangle
        let arrowLength: CGFloat = end.x - start.x - 220 // Adjust the length based on the distance between rectangles
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength, y: 0)) // End slightly to the left of the target rectangle
        
        // Create the arrowhead
        let arrowWidth: CGFloat = 20 // Width of the arrowhead
        path.move(to: CGPoint(x: start.x + 110 + arrowLength, y: 0))
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength - arrowWidth, y: arrowWidth))
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength, y: 0))
        path.addLine(to: CGPoint(x: start.x + 110 + arrowLength - arrowWidth, y: -arrowWidth))
        path.close() // Connects the last point with the first point to close the path
        
        let arrowNode = SKShapeNode(path: path.cgPath)
        arrowNode.strokeColor = .lightGray
        arrowNode.lineWidth = 8 // Make the line bolder
        arrowNode.fillColor = .lightGray
        
        return arrowNode
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
        
        // Snap the circle to the center of the target rectangle if it's released within its bounds
        if targetRectangleNode.frame.contains(circleNode.position) {
            circleNode.position = targetRectangleNode.position
        } else {
            // If not dropped in the target, return the circle to the starting rectangle
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
        isDraggingCircleNode = false // Reset dragging state
    }
}
