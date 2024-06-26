//
//  Test9View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 04.04.24.
//

import SwiftUI
import StringMetric

struct Test10View: View {
    @ObservedObject private var speechRecognitionManager = SpeechRecognitionManager.shared
    @State private var finished = false
    @State private var currentImage: BNT_Picture?  // Use BNT_Picture instead of String
    @State private var timer: Timer?
    @State private var unusedImages: [BNT_Picture]  // Store BNT_Picture objects
    @State private var recognizedImages: [String] = []
    
    init() {
        // Initialize with BNT_Picture objects from BNTPictureList
        let bntPictureList = BNTPictureList()
        _unusedImages = State(initialValue: bntPictureList.pictures)
    }

    var body: some View {
        BaseTestView(showCompletedView: $finished, indexOfCircle: 10, textOfCircle: "10", destination: { Test11View() }, content: {
            
            AudioIndicatorView()
            
            VStack {
                if let image = currentImage {  // Use currentImage of type BNT_Picture
                    Image(image.file_name)  // Access file_name from BNT_Picture
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                }
            }
            .onAppear(perform: {
                try! AudioService.shared.startRecording(to: "test10")
                setNextImage()
                //startTimer()
            })
            .onChange(of: speechRecognitionManager.recognizedWords) { words in
                checkLastWord(words: words)
            }
            .onDisappear {
                AudioService.shared.stopRecording()
                //stopTimer()
            }
            .onTimerComplete(duration: 60, onComplete: {
                print(recognizedImages)
                AudioService.shared.stopRecording()
                finished.toggle()
            })
            
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 10")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack{
                Text("Ihre zehnte Aufgabe besteht darin, soviele ")
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
                
                Text("Ihnen automatisch das nächste Bild gezeigt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,120)
        }, completedContent: { onContinue in
            CompletedView(completedTasks: 10, onContinue: onContinue)
        })
    }
    
    func checkLastWord(words: [String]) {
        guard let lastWord = words.last, let currentName = currentImage?.name, let maxDistance = currentImage?.maxDistance else { return }
        
        if (lastWord.distanceLevenshtein(between: currentName) <= maxDistance) {
            setNextImage()
            speechRecognitionManager.removeLastWord()
            recognizedImages.append(currentName)
        }
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
    Test10View()
}
