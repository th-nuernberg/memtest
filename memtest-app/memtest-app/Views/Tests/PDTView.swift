//
//  Test10View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 04.04.24.
//

import SwiftUI

/// `PDTView` represents the View for the Picture Description Task (PDT) where participants are asked to describe a given picture.
///
/// - Parameters:
///   - onNextView: A closure to navigate to the next view.
///
struct PDTView: View {
    
    var onNextView: (() -> Void)?
    
    @State private var finished = false
    @State private var showExplanation = true
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,
                     showExplanationView: $showExplanation,
                     indexOfCircle: 12,
                     textOfCircle:"12", content: {
            VStack{
                
                BaseHeaderViewNotSKT(
                    showAudioIndicator: true,
                    onBack: {
                        onComplete()
                    },
                    onNext: {
                        onComplete()
                    }
                )
                
                GeometryReader { geometry in
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            Image("Test12Assets/Cookie_Theft_Picture")
                                .resizable()
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }.onAppear(perform: {
                do {
                    try AudioService.shared.startRecording(to: "pdt")
                    print("Recording started")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: SettingsService.shared.getTestDuration()) {
                print("Timer completed")
                onComplete()
                AudioService.shared.stopRecording()
            }
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
                    Text("Aufgabenstellung PDT")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack{
                    Text("Ihnen wird gleich ein Bild gezeigt.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                    
                    Text("Bitte beschreiben Sie was auf diesem zu sehen ist.")
                        .font(.custom("SFProText-SemiBold", size: 40))
                        .foregroundStyle(Color(hex: "#5377A1"))
                        .padding(.top, 20)
                }
                .padding(.top,120)
            })
            
        }, completedContent: { onContinue in
            CompletedView(numberOfTasks: 1, completedTasks: 1, onContinue: {
                onNextView?()
                onContinue()
            }, customButtonText: "Beenden ➔")
        })
    }
    
    /// Function to handle completion of the test
    ///
    /// Actions:
    /// - mark test as finished
    /// - Saves Test-Results
    /// - Stops recording
    private func onComplete() {
        DataService.shared.savePDTResults()
        finished = true
        AudioService.shared.stopRecording()
    }
}

#Preview {
    PDTView()
}
