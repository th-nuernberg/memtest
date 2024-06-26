//
//  VFTView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 04.04.24.
//

import SwiftUI
import Combine

/// `VFTView` represents the View for the Verbal Fluency Test (VFT) where participants are asked to name animal names.
///
/// - Parameters:
///   - onNextView: A closure to navigate to the next view.
///
struct VFTView: View {
    
    var onNextView: (() -> Void)?
    
    @ObservedObject private var speechRecognitionManager = SpeechRecognitionManager.shared
    
    let wordChecker = AnimalNameChecker()
    
    @State private var cancellables = Set<AnyCancellable>()
    @State private var finished = false
    @State private var showExplanation = true
    @State private var recognizedAnimalNames: [String] = []
    private let testDuration = SettingsService.shared.getTestDuration()
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, showExplanationView: $showExplanation, indexOfCircle: 10, textOfCircle: "10", content: {
            VStack {
                
                BaseHeaderViewNotSKT(
                    showAudioIndicator: true,
                    onBack: {
                        onComplete()
                    },
                    onNext: {
                        onComplete()
                    }
                )
                
                VStack {
                    Text("Bitte nennen Sie Tiernamen")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                }
                Spacer()
                HStack {
                    Spacer()
                    AvatarView(gifName: "Avatar_Nicken_fast")
                    Spacer()
                    HourglassView(size: 300, lineWidth: 15, duration: testDuration)
                        .padding(.trailing, 150)
                }
            }
            .padding()
            .onAppear(perform: {
                try! AudioService.shared.startRecording(to: "vft")
                self.speechRecognitionManager.$recognizedWords
                    .sink { _ in
                        self.updateErkannteTiernamen()
                    }
                    .store(in: &cancellables)
            })
            .onTimerComplete(duration: testDuration, onComplete: {
                DataService.shared.saveVFTResults(recognizedAnimalNames: self.recognizedAnimalNames)
                AudioService.shared.stopRecording()
                finished = true
            })
        }, explanationContent: { onContinue in
            
            ExplanationView(onNext: {
                showExplanation.toggle()
            }, showProgressCircles: false, content: {
                HStack {
                    Spacer()
                    Button(action: {
                        self.onNextView?()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                    }
                    Text("Aufgabenstellung VFT")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack{
                    Text("Ihnen wird gleich eine Kategorie genannt")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("und Sie sollen so schnell wie möglich alle Dinge aufzählen,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("die in diese Kategorie gehören.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Wenn die Kategorie 'Kleidungsstücke' lautet,")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                    
                    Text("können Sie 'Hemd', 'Krawatte' oder 'Hut', usw. aufzählen.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                }
                .padding(.top, 120)
            })
            
        }, completedContent: { onContinue in
            CompletedView(numberOfTasks: 1, completedTasks: 1, onContinue: {
                onNextView?()
                onContinue()
            }, customButtonText: "Beenden ➔")
        })
    }
    
    /// Updates the list of recognized animal names based on the recognized words
    private func updateErkannteTiernamen() {
        var tempSet = Set(recognizedAnimalNames)
        for word in speechRecognitionManager.recognizedWords {
            if wordChecker.checkWord(word) {
                let (inserted, _) = tempSet.insert(word)
                if inserted {
                    recognizedAnimalNames.append(word)
                }
            }
        }
    }
    
    /// Function to handle completion of the test
    ///
    /// Actions:
    /// - mark test as finished
    /// - Stops recording
    private func onComplete() {
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    VFTView()
}
