//
//  TipCalibrationExampleScene.swift
//  memtest-app
//
//  Created by Jonathan Wilisch on 31.03.24.
//

import SwiftUI
import SpriteKit

struct TipExampleSceneContainerView: UIViewRepresentable {
    
    @Binding var calibrationComplete: Bool
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context){
        if uiView.scene == nil {
            let scene = TipExampleScene(size: uiView.bounds.size)
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Center the anchor point
            uiView.presentScene(scene)
        } else {
            uiView.scene?.size = uiView.bounds.size
        }
        
        if let scene = uiView.scene as? TipExampleScene {
            scene.calibrationCompleteBinding = $calibrationComplete
        }
    }
}

class TipExampleScene: SKScene{
    var circleNode: SKShapeNode!
    var circleNodeSelected = false
    var startingRectangleNode: SKShapeNode!
    var targetRectangleNode: SKShapeNode!
    var arrowNode: SKShapeNode!
    var calibrationCompleteBinding: Binding<Bool>?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    
    func setupScene(){
        self.backgroundColor = .white
        self.removeAllChildren()
        
        let rectangleSize = CGSize(width:200, height:200)
        
        startingRectangleNode = SKShapeNode(rectOf: rectangleSize, cornerRadius: 10)
        startingRectangleNode.fillColor = .lightGray
        startingRectangleNode.position = CGPoint(x: -rectangleSize.width, y: 0)
        self.addChild(startingRectangleNode)
        
        targetRectangleNode = SKShapeNode(rectOf: rectangleSize, cornerRadius: 10)
        targetRectangleNode.fillColor = .lightGray
        targetRectangleNode.position = CGPoint(x: rectangleSize.width, y: 0)
        targetRectangleNode.name = "targetRectangle"
        self.addChild(targetRectangleNode)
        
        arrowNode = createArrowNode(from: startingRectangleNode.position, to: targetRectangleNode.position)
                self.addChild(arrowNode)
        
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
    
    func touchDown(atPoint pos : CGPoint){
        
        if(circleNodeSelected){
            if(targetRectangleNode.contains(pos)){
                circleNode.position = targetRectangleNode.position
                circleNodeSelected = false
                calibrationCompleteBinding?.wrappedValue = true
            } else if(startingRectangleNode.contains(pos)){
                circleNode.position = startingRectangleNode.position
                circleNodeSelected = false
            }
        }else if(!circleNodeSelected && circleNode.contains(pos)){
            circleNodeSelected = true
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            touchDown(atPoint: pos)
        }
    }
}
