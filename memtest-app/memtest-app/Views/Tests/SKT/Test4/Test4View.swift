//
//  Test4View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

/// representing a numbered circle with a specific color --> playing stone
struct NumberCircles {
    var number: Int
    var color: UIColor
}

/// representing a drop zone circle --> circle where stones can be dragged to
/// optional with number
struct DropZoneCircle {
    var number: Int?
}

/// `Test4View` serves as the Test 4 of the SKT-Tests
///
/// Features:
/// - Displays draggable elements with numbers for the user to sort
/// - Provides explanation and instructions before starting the test
struct Test4View: View {
    @Binding var currentView: SKTViewEnum
    @State private var finished = false
    @State private var showExplanation = true
    
    // List of elements with numbers and colors
    // elements represent the stones on the board of the real skt test
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
    
    // variable to keep track of user-sorted elements
    @State var userSortedElements: [DragElement] = []
    
    public init(currentView: Binding<SKTViewEnum>) {
        self._currentView = currentView
    }
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 4,
                     textOfCircle: "4", content: {
            
            // Header view with audio indicator, back and next buttons
            BaseHeaderView(
                showAudioIndicator: false,
                currentView: $currentView,
                onBack: {
                    // Navigate to the previous test
                    self.currentView = .skt3
                    onComplete()
                },
                onNext: {
                    // Navigate to the next test
                    self.currentView = .skt5
                    onComplete()
                }
            )
            
            DragNDropContainerView(dragElements: dragElements, dropZones: OrderNumberTestService.shared.getDropZones(), onPositionsChanged: { updatedDragElements in
                OrderNumberTestService.shared.setDragElements(dragElements: updatedDragElements)
                // Check if the elements are in order and complete if they are
                checkOrderAndComplete(dragElements: updatedDragElements)
                userSortedElements = updatedDragElements
            })
            .onTimerComplete(duration: SettingsService.shared.getTestDuration()) {
                print("Timer completed")
                onComplete()
            }
            
        }, explanationContent: { onContinue in
            // Explanation content
            ExplanationView(onNext: {
                showExplanation.toggle()
            }, circleIndex: 4, circleText: "4", showProgressCircles: true, content: {
                HStack {
                    Text("Aufgabenstellung 4")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack {
                    Text("Wie Sie sehen, sind die Zahlen nicht geordnet.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Kleine und große Zahlen sind durcheinander gemischt.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Bitte ordnen Sie jetzt, so schnell Sie können,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                    
                    Text("die Zahlen der Größe nach.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Dazu suchen Sie die kleinste Zahl ")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                    
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
                .padding(.top, 120)
            })
            
        }, completedContent: { onContinue in
            // Completed Test4
            CompletedView(completedTasks: 4, onContinue: {
                // Navigate to the next test
                currentView = .skt5
                onContinue()
            })
        })
    }
    
    /// Checks if the elements are sorted in ascending order and calls `onComplete` if they are
    private func checkOrderAndComplete(dragElements: [DragElement]) {
        let sortedByLabel = dragElements.sorted(by: { Int($0.label ?? "") ?? 0 < Int($1.label ?? "") ?? 0 })
        let sortedByPosition = sortedByLabel.sorted(by: { $0.posIndex < $1.posIndex })
        
        if sortedByLabel == sortedByPosition && sortedByLabel.first?.posIndex == 0 && dragElements.last?.posIndex == (dragElements.count - 1) {
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
        DataService.shared.saveSKT4Results(dragElements: self.userSortedElements)
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    Test4View(currentView: .constant(.skt4))
}
