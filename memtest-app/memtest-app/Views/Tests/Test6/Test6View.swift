//
//  Test5View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI
import Combine


struct Test6View: View {
    @StateObject private var viewModel: SymbolViewModel = SymbolViewModel()
    @State private var finished = false
    
    @State private var userSymbolCount = ""
    
    
    var body: some View {
        BaseTestView(showCompletedView: $finished,indexOfCircle: 6,
                     textOfCircle:"6", destination: {Test7View()}, content: {
            
            VStack{
                AudioIndicatorView()
                
                VStack (spacing: 0){
                    Text("Gesucht: \(viewModel.selectedSymbol ?? "")")
                        .font(.custom("SFProText-Bold", size: 40))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    SymbolView(viewModel: viewModel)
                        .padding()
                }
                
                //Text("Stern \(viewModel.symbolCounts["★"] ?? 0), Flocke \(viewModel.symbolCounts["✻"] ?? 0), Form \(viewModel.symbolCounts["▢"] ?? 0) ")
                //Text("\(viewModel.selectedSymbolCount)")
                
                HStack{
                    TextField("Anzahl der Symbole:", text: $userSymbolCount)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .onReceive(Just(userSymbolCount)) { newValue in
                            let filtered = String(newValue.filter { $0.isNumber })
                            if let count = Int(filtered), count > 200 {
                                userSymbolCount = String(filtered.prefix(filtered.count - 1))
                            } else {
                                userSymbolCount = filtered
                            }
                        }
                        .padding(.trailing, 20)
                    
                    Button(action: {
                        AudioService.shared.stopRecording()
                        finished.toggle()
                    }) {
                        Text("OK")
                            .font(.custom("SFProText-SemiBold", size: 25))
                            .foregroundStyle(.white)
                    }
                    .padding(13)
                    .background(.blue)
                    .cornerRadius(10)
                }
                .padding(20)
            }
            .onAppear(perform: {
                do {
                    try AudioService.shared.startRecording(to: "test6")
                    print("Recording started")
                } catch {
                    print("Failed to start recording: \(error)")
                }
            })
            .onTimerComplete(duration:60) {
                print("Timer completed")
                finished = true
                AudioService.shared.stopRecording()
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
                Text("Sie sehen hier auf dieser Tafel verschiedene Symbole:")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Vierecke, Sterne und Blumen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Wichtig sind nur die gesuchten Symbole.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Zählen Sie bitte laut und so schnell Sie können")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("alle gesuchten Symbole, die zu sehen sind.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Bitte zählen Sie die gesuchten Symbole Zeile für Zeile,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("von links nach rechts,")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("indem Sie mit dem Zeigefinger auf jedes Symbol deuten.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sind Sie fertig drücken Sie auf den OK Knopf.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
            }
            .padding(.top,60)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 6, onContinue: onContinue)
        })
    }
}

#Preview {
    Test6View()
}
