//
//  Test8View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 04.04.24.
//

import SwiftUI
import Combine

struct Test9View: View {
    @ObservedObject private var speechRecognitionManager = SpeechRecognitionManager.shared
    
    let wordChecker = AnimalNameChecker()
    
    @State private var cancellables = Set<AnyCancellable>()
    @State private var finished = false
    @State private var recognizedAnimalNames: [String] = []

    var body: some View {
        BaseTestView(showCompletedView: $finished, indexOfCircle: 9, textOfCircle: "9", destination: { Test10View() }, content: {
            VStack {
                AudioIndicatorView()
                Spacer()
       
                Text("Alle genannten Tiere:")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                ScrollView {
                   VStack(alignment: .leading, spacing: 10) {
                       ForEach(recognizedAnimalNames, id: \.self) { tiername in
                           HStack {
                               RoundedRectangle(cornerRadius: 20)
                                   .fill(Color.gray.opacity(0.2))
                                   .frame(height: 50)
                                   .overlay(
                                       Text(tiername)
                                           .foregroundColor(Color.black)
                                   )
                               Spacer()
                           }.padding(.horizontal)
                       }
                   }
                   .padding(.top)
                }
                
                Spacer()
                //Text("\(speechRecognitionManager.recognizedWords.last ?? "")")
            }
            .padding()
            .onAppear(perform: {
                try! AudioService.shared.startRecording(to: "test9")
                self.speechRecognitionManager.$recognizedWords
                    .sink { _ in
                        self.updateErkannteTiernamen()
                    }
                    .store(in: &cancellables)
            })
            .onTimerComplete(duration: 60, onComplete: {
                AudioService.shared.stopRecording()
                finished = true
            })
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 9")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack{
                Text("Ihre neunte Aufgabe besteht darin, soviele")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Tiere wie möglich zu benennen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sagen sie zum Beispiel Hund,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("die App wird dann automatisch das Wort erkennen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("und das Wort Hund wird angezeigt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
            }
            .padding(.top,120)
        }, completedContent: { onContinue in
            CompletedView(completedTasks: 9, onContinue: onContinue)
        })
    }
    
    // temporär -> nutze germanet
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
}

#Preview {
    Test9View()
}
