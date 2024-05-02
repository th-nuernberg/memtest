//
//  Test5View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 29.04.24.
//

import SwiftUI

struct Test5View: View {
    @State private var finished = false
    
    @State private var dragElements: [DragElement] = []
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 5,
                     textOfCircle:"5", destination: {Test6View()}, content: {
            
            DragNDropContainerView(dragElements: OrderNumberTestService.shared.getDragElements(), dropZones: OrderNumberTestService.shared.getDropZones(), onPositionsChanged: { updatedDragElements in
                self.dragElements = updatedDragElements
                // if the updatedDragElements are on the there starting positions, the onComplete function should be called
                // the right place is defined by if the dragElement.label is the same as the dropZone.label on the same index
                checkElementsPosition(updatedDragElements: updatedDragElements)
            })
            
            Text("test5")
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                onComplete()
            }
                        
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 5")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Stellen Sie jetzt bitte, so schnell Sie können,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text(" die Spielsteine wieder auf ihren alten Platz zurück.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Die Zahl 17 also auf das Feld Nummer 17 usw.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 5, onContinue: onContinue)
        })
    }
    
    private func checkElementsPosition(updatedDragElements: [DragElement]) {
        let dropZones = OrderNumberTestService.shared.getDropZones()
        
        // Check if all elements are in their starting positions
        let mispositionedElements = updatedDragElements.filter { element in
            // check if dropZone has a lable if not, the drop Position is not valid
            guard let label = element.label, let dropZoneLabel = dropZones[element.posIndex].label, element.posIndex < dropZones.count else {
                return true // Include if there's any issue with index conversion or range
            }
            // if the dragElement.label and the dropZoneLabel are the same return false
            return !(dropZones[element.posIndex].label!.contains(label) || label.contains(dropZones[element.posIndex].label!))
        }
        
        // complete the test if the dragElements are in their starting positions
        if mispositionedElements.isEmpty {
            onComplete()
        }
    }
    
    private func onComplete() {
        // TODO: save dragElements in json
        
        finished = true
    }
}

#Preview {
    Test5View()
}
