//
//  Test5View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI
import Combine


struct Test5View: View {
    
    @StateObject private var viewModel = SymbolViewModel()
    @State private var finished = false
    
    @State private var userSymbolCount = ""
    
    
    var body: some View {
        BaseTestView(showCompletedView: $finished, destination: {Test6View()}, content: {
            Text("Gesucht: ")
            Spacer()
            SymbolView(viewModel: viewModel)
            Spacer()
            Text("\(viewModel.symbolCounts["★"] ?? 0)")
            
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
                    finished.toggle()
                }) {
                    Text("OK")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(.white)
                }
                .padding(13)
                .background(.blue)
                .cornerRadius(10)
                //.padding(.top,70)
                //.padding(.leading)
                //.frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            
            
            
        }, explanationContent: {
            HStack {
                HStack {
                    ForEach(0..<3) { index in
                        ZStack {
                            Circle()
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                        }
                        .padding(.trailing, 5)
                    }
                }
                
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
                HStack {
                    ForEach(0..<3) { index in
                        ZStack {
                            if index == 0 {
                                Circle()
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                Text("5")
                                    .font(.title)
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding(.trailing, 5)
                    }
                }
            }
            
            HStack {
                Text("Aufgabenstellung 5")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            VStack{
                Text("Ihre fünfte Aufgabe besteht darin, das")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("gesuchte Symbol zu zählen und als Antwort")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("zurück zu geben wie oft Sie dieses gefunden haben.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sie werden gleich eine große Anzahl an Symbolen sehen.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                    .padding(.top,20)
                
                Text("Oben rechts wird Ihnen immer angezeigt, was das gesuchte")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Smybol ist. Diese zählen Sie und geben es entweder unten")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("in das Eingabefeld ein oder sagen es laut und deutlich.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
                Text("Sind Sie fertig drücken Sie auf den OK Knopf.")
                    .font(.custom("SFProText-SemiBold", size: 40))
                    .foregroundStyle(Color(hex: "#5377A1"))
                
            }
            .padding(.top,120)
        }, completedContent: {onContinue in
            CompletedView(completedTasks: 5, onContinue: onContinue)
        })
    }
}

#Preview {
    Test5View()
}
