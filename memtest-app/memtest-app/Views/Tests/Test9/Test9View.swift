//
//  Test9View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 04.04.24.
//

import SwiftUI

struct Test9View: View {
    @ObservedObject private var speechRecognitionManager = SpeechRecognitionManager.shared
    @State private var finished = false
    @State private var currentImage: String?
    @State private var timer: Timer?
    @State private var unusedImages: [String]

    init() {
        _unusedImages = State(initialValue: (1...15).map { "Test9Assets/\($0)" })
    }

    var body: some View {
        BaseTestView(showCompletedView: $finished, indexOfCircle: 8, textOfCircle: "9", destination: { Test10View() }, content: {
            
            AudioIndicatorView()
            
            VStack {
                if let imageName = currentImage {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                }
            }
            .onAppear(perform: {
                try! AudioService.shared.startRecording(to: "test9")
                setNextImage()
                startTimer()
            })
            .onDisappear {
                AudioService.shared.stopRecording()
                stopTimer()
            }
            
        }, explanationContent: {
            VStack{
                Text("Ihre neunte Aufgabe besteht darin, soviele ")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Schwarz-/Weißbilder zu erkennen und zu benennen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("wie möglich.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sehen sie zum Beispiel einen Baum,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("sagen Sie laut und deutlich Baum.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Ist das Bild erfolgreich benannt worden, wird")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Ihnen automatisch das nächste Bild gezeigt werden.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,120)
        }, completedContent: { onContinue in
            CompletedView(completedTasks: 9, onContinue: onContinue)
        })
    }
    
    func setNextImage() {
        if !unusedImages.isEmpty {
            let randomIndex = Int.random(in: 0..<unusedImages.count)
            currentImage = unusedImages[randomIndex]
            unusedImages.remove(at: randomIndex)
        } else {
            finished = true
            stopTimer()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            setNextImage()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    Test9View()
}
