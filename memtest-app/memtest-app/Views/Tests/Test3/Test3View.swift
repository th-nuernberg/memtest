//
//  Test3View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test3View: View {
    
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
    
    let dropZones: [DropZone] = [
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(),
        DropZone(label: "10"),
        DropZone(label: "81"),
        DropZone(label: "72"),
        DropZone(label: "95"),
        DropZone(label: "84"),
        DropZone(label: "73"),
        DropZone(label: "16"),
        DropZone(label: "13"),
        DropZone(label: "29"),
        DropZone(label: "40"),

    ]
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 3,
                     textOfCircle:"3", destination: {Test4View()}, content: {
            AudioIndicatorView()
            Spacer()
            
            DragNDropContainerView(dragElements: dragElements, dropZones: dropZones, isDragEnabled: false, onPositionsChanged: { positions in
                
            })
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
            }
            .onAppear(perform: {
                try! AudioService.shared.startRecording(to: "test3")
            })
            
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 3")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre dritte Aufgabe besteht darin, die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Ihnen gezeigten Zahlen zu lesen und zu bennenen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Zum Beispiel sehen Sie die Zahl 12, dann")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("sagen Sie laut und deutlich zwölf.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 3, onContinue: onContinue)
        })
    }
}

#Preview {
    Test3View()
}
