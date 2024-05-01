//
//  Test4View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct NumberCircles {
    var number: Int
    var color: UIColor
}

struct DropZoneCircle {
    var number: Int?
}

struct Test4View: View {
    
    @State private var finished = false
    
    let dragElements: [DragElement] = [
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
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 4,
                     textOfCircle:"4", destination: {Test5View()}, content: {
            DragNDropContainerView(dragElements: dragElements, dropZones: OrderNumberTestService.shared.getDropZones(), onPositionsChanged: { updatedDragElements in
                OrderNumberTestService.shared.setDragElements(dragElements: updatedDragElements)
            })
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                onComplete()
            }
                        
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 4")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre vierte Aufgabe besteht darin, die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("angezeigten Zahlen zu ordnen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sie ziehen dabei mit ihrem Finger die Zahl")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("die Sie ordnen wollen an die Stelle, an die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("gewünschte Stelle.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 4, onContinue: onContinue)
        })
    }
    
    private func onComplete() {
        // TODO: save currentDragElements in json
        finished = true
    }
}

#Preview {
    Test4View()
}
