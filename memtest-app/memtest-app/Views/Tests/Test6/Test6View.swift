//
//  Test6View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test6View: View {
    @ObservedObject private var manager = SpeechRecognitionManager.shared
    @State private var isRecording = false
    @State private var finished = false

    private var symbolList = TestSymbolList()
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 5,
                     textOfCircle:"6", destination: {Test7View()}, content: {
            Text(manager.recognizedWords.last ?? "")
            
            LazyVGrid(columns: columns) {
                ForEach(symbolList.symbols, id: \.name) { symbol in
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                            .frame(width: 200)
                            .cornerRadius(20)
                            .padding(.bottom, 20)
                        
                        
                        if (self.isSymbolNameRecognized(symbol.name)) {
                            Image(symbol.fileUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .offset(x: 5, y: -5)
                        }
                    }
                }
            }
            .padding(.vertical)
            .padding(.top, 70)
            .onAppear(perform: {
                do {
                    try AudioService.shared.startRecording(to: "test6")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
                // TODO: route to Test2View --> trigger navigateToDestination() in BaseTestView
            }
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 6")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre sechste Aufgabe besteht darin, die")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Bilder aus der Lernphase jetzt noch")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("einmal zu bennenen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Zum Beispiel haben Sie vorhin einen Baum gesehen, sagen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("Sie jetzt klar un deutlich das Wort Baum.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Die erkannten Symbole werden dann automatisch")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("als erfolgreich erkannt markiert.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 6, onContinue: onContinue)
        })
    }
    
    // TODO: implement germanet and similarity comparison
    private func isSymbolNameRecognized(_ name: String) -> Bool {
        return manager.recognizedWords.contains { $0.lowercased().contains(name.lowercased()) }
    }
}



#Preview {
    Test6View()
}
