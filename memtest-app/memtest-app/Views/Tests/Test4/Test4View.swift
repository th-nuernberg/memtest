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
    @Binding var currentView: SKTViewEnum
    
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
    
    public init(currentView: Binding<SKTViewEnum>) {
        self._currentView = currentView
    }
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 4,
                     textOfCircle:"4", destination: {Test5View(currentView: .constant(.skt5))}, content: {
            DragNDropContainerView(dragElements: dragElements, dropZones: OrderNumberTestService.shared.getDropZones(), onPositionsChanged: { updatedDragElements in
                OrderNumberTestService.shared.setDragElements(dragElements: updatedDragElements)
                // if the updatedDragElements are in an ascending order regarding the label and the lowest label number element is on posIndex 0 and the highest label number is on posIndex (dragElements.count - ), the onComplete function is called
                checkOrderAndComplete(dragElements: updatedDragElements)
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
                Text("Wie Sie sehen, sind die Zahlen nicht geordnet.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Kleine und große Zahlen sind durcheinander gemischt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Bitte ordnen Sie jetzt, so schnell Sie können,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("die Zahlen der Größe nach.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Dazu suchen Sie die kleinste Zahl ")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("und ziehen sie auf das erste Feld links oben.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Dann suchen Sie die nächstgrößere Zahl")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text(" und ziehen Sie daneben und so weiter.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 4, onContinue: {
                currentView = .skt5
                onContinue()
            })
        })
    }
    
    private func checkOrderAndComplete(dragElements: [DragElement]) {
        let sortedByLabel = dragElements.sorted(by: { Int($0.label ?? "") ?? 0 < Int($1.label ?? "") ?? 0 })
        let sortedByPosition = sortedByLabel.sorted(by: { $0.posIndex < $1.posIndex })
        
        if sortedByLabel == sortedByPosition && sortedByLabel.first?.posIndex == 0 && dragElements.last?.posIndex == (dragElements.count - 1) {
            onComplete()
        }
    }
    
    private func onComplete() {
        // TODO: save currentDragElements in json
        finished = true
    }
}

#Preview {
    Test4View(currentView: .constant(.skt4))
}
