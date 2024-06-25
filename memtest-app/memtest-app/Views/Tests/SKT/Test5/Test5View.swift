//
//  Test5View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 29.04.24.
//

import SwiftUI

/// `Test5View` serves as the Test 5 of the SKT-Tests
///
/// Features:
/// - Displays draggable elements for the user to return to their original positions
/// - Provides explanation and instructions before starting the test
struct Test5View: View {
    @Binding var currentView: SKTViewEnum
    @State private var finished = false
    @State private var showExplanation = true
    
    // variable to keep track of draggable elements
    @State private var dragElements: [DragElement] = []
    
    public init(currentView: Binding<SKTViewEnum>) {
        self._currentView = currentView
    }
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 5,
                     textOfCircle: "5", content: {
            
            // Header view with audio indicator, back and next buttons
            BaseHeaderView(
                showAudioIndicator: false,
                currentView: $currentView,
                onBack: {
                    // Navigate to the previous test
                    self.currentView = .skt4
                    onComplete()
                },
                onNext: {
                    // Navigate to the next test
                    self.currentView = .skt6
                    onComplete()
                }
            )
            
            DragNDropContainerView(dragElements: OrderNumberTestService.shared.getDragElements(), dropZones: OrderNumberTestService.shared.getDropZones(), onPositionsChanged: { updatedDragElements in
                self.dragElements = updatedDragElements
                // Check if the elements are in their original positions and complete if they are
                checkElementsPosition(updatedDragElements: updatedDragElements)
            })
            
            Text("test5")
                .onTimerComplete(duration: SettingsService.shared.getTestDuration()) {
                    onComplete()
                }
            
        }, explanationContent: { onContinue in
            // Explanation content
            ExplanationView(onNext: {
                showExplanation.toggle()
            }, circleIndex: 5, circleText: "5", showProgressCircles: true, content: {
                HStack {
                    Text("Aufgabenstellung 5")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack {
                    Text("Stellen Sie jetzt bitte, so schnell Sie können,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("die Spielsteine wieder auf ihren alten Platz zurück.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Die Zahl 17 also auf das Feld Nummer 17 usw.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                }
                .padding(.top, 120)
            })
            
        }, completedContent: { onContinue in
            // Completed Test5
            CompletedView(completedTasks: 5, onContinue: {
                // Navigate to the next test
                currentView = .skt6
                onContinue()
            })
        })
    }
    
    /// Checks if the elements are in their original positions and calls `onComplete` if they are
    private func checkElementsPosition(updatedDragElements: [DragElement]) {
        let dropZones = OrderNumberTestService.shared.getDropZones()
        
        // Check if all elements are in their starting positions
        let mispositionedElements = updatedDragElements.filter { element in
            // Check if dropZone has a label; if not, the drop position is not valid
            guard let label = element.label, let dropZoneLabel = dropZones[element.posIndex].label, element.posIndex < dropZones.count else {
                return true // Include if there's any issue with index conversion or range
            }
            // If the dragElement.label and the dropZoneLabel are the same, return false
            return !(dropZones[element.posIndex].label!.contains(label) || label.contains(dropZones[element.posIndex].label!))
        }
        
        // Complete the test if the dragElements are in their starting positions
        if mispositionedElements.isEmpty {
            onComplete()
        }
    }
    
    /// Function to handle completion of the test
    ///
    /// Actions:
    /// - mark test as finished
    /// - Filters Test-Results and saves them
    /// - Stops recording
    private func onComplete() {
        DataService.shared.saveSKT5Results(dragElements: self.dragElements)
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    Test5View(currentView: .constant(.skt5))
}
