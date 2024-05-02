//
//  Test1View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test1View: View {
    
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
        BaseTestView(showCompletedView: $finished,indexOfCircle: 0,
                     textOfCircle:"1", destination: {Test2View()}, content: {
            AudioIndicatorView()
            
            LazyVGrid(columns: columns) {
                ForEach(symbolList.symbols, id: \.name) { symbol in
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                            .frame(width: 200)
                            .cornerRadius(20)
                            .padding(.bottom, 20)
                        
                        Image(symbol.fileUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .offset(x: 5, y: -5)
                    }
                }
            }
            .padding(.vertical)
            .padding(.top, 70)
            .onAppear(perform: {
                manager.recognizedWords = []
                do {
                    try AudioService.shared.startRecording(to: "test1")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration: 60) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
            }
        }, explanationContent: {
            HStack {
                Text("Aufgabenstellung 1")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            
            Spacer()
            VStack{
                Text("Es werden Ihnen nun Bilder von Gegenständen gezeigt,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 8)
                
                Text(" die Sie alle schon einmal gesehen haben,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 8)
                
                Text("die Ihnen also bekannt sind.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 8)

                Text("Es kommt jetzt darauf an, dass Sie, so schnell Sie können,  ")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 8)
                
                Text("sagen, wie man die Gegenstände benennt oder wie sie heißen")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 8)
                
                Text("und dass Sie sich die Gegenstände gleichzeitig auch einprägen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 8)

                Text("Sie werden nämlich später noch einmal nach diesen gefragt.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top, 8)
            }
            .padding(.top, 40)
            
            Spacer()
            
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 1, onContinue: onContinue)
        })
    }
    
    private func startStopRecording() {
        if isRecording {
            AudioService.shared.stopRecording {
                listRecordedFiles()
            }
        } else {
            do {
                try AudioService.shared.startRecording(to: "test1")
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
        isRecording.toggle()
    }
    
    private func listRecordedFiles() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }
            print("Recorded files:")
            for file in audioFiles {
                print(file.lastPathComponent)
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
    
}


#Preview {
    Test1View()
}
