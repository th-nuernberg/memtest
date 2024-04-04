//
//  BaseTestView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 15.03.24.
//

import SwiftUI

typealias ContinueHandler = () -> Void

struct BaseTestView<Destination: View, Content: View, ExplanationContent: View, CompletedContent: View>: View {
    let destination: () -> Destination
    let content: () -> Content
    var explanationContent: () -> ExplanationContent?
    var completedContent: (@escaping ContinueHandler) -> CompletedContent?
    @Binding private var showCompletedView: Bool
    @State var showNextView: Bool = false
    @State private var showExplanation: Bool
    private var circleText: String;
    private var circleIndex: Int;
    
    
    
    
    init(showCompletedView: Binding<Bool>, indexOfCircle: Int,
         textOfCircle: String, destination: @escaping () -> Destination, @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder explanationContent: @escaping () -> ExplanationContent? = { nil }, @ViewBuilder completedContent: @escaping (@escaping ContinueHandler) -> CompletedContent? = { _ in nil }) {
        self.destination = destination
        self.content = content
        self.explanationContent = explanationContent
        self.completedContent = completedContent
        self._showExplanation = State(initialValue: self.explanationContent() != nil)
        self._showCompletedView = showCompletedView
        self.circleText = textOfCircle
        self.circleIndex = indexOfCircle
    }
    
    var body: some View {
        NavigationStack {
            if showExplanation, let explanation = explanationContent() {
                ExplanationView(circleIndex:circleIndex,circleText: circleText,content: { explanation }, onContinue: {
                    showExplanation = false
                })
            } else {
                VStack {
                    if (showCompletedView == false) {
                        content()
                    } else {
                        // completedContent must have onContinue
                        completedContent({
                            showNextView = true
                        })
                    }
                }
                .navigationDestination(isPresented: $showNextView, destination: destination)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func navigateToDestination() {
        showNextView = true
    }
}


struct ExplanationView<Content: View>: View {
    let content: Content
    var onContinue: () -> Void
    
    var circleIndex: Int
    var circleText: String
    
    init(circleIndex: Int,
         circleText: String,@ViewBuilder content: () -> Content, onContinue: @escaping () -> Void) {
        self.content = content()
        self.onContinue = onContinue
        self.circleIndex = circleIndex
        self.circleText = circleText
    }
    
    var body: some View {
        HStack {
            HStack {
                ForEach(0..<10) { index in
                    ZStack {
                        if index == circleIndex {
                            Circle()
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                            Text(circleText)
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
        
        VStack {
            content
            Spacer()
            VStack {
                Spacer()
                Button(action: onContinue) {
                    Text("Weiter")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal,50)
                .background(Color.blue)
                .cornerRadius(10)
                .navigationBarBackButtonHidden(true)
            }
            .padding()
        }
    }
}

struct CompletedView: View {
    var numberOfTasks: Int = 7 // Total number of tasks
    var completedTasks: Int = 1 // Number of tasks completed
    var onContinue: ContinueHandler
    
    var buttonText: String {
        if completedTasks == 1 {
            return "zweiten"
        } else if completedTasks == 2 {
            return "dritten"
        } else if completedTasks == 3 {
            return "vierten"
        } else if  completedTasks == 4 {
            return "fünften"
        } else if  completedTasks == 5 {
            return "sechsten"
        } else if  completedTasks == 6 {
            return "siebten"
        } else {
            return "nächsten"
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Die Aufgabe ist abgeschlossen.\nMachen Sie eine kurze Pause.")
                .font(.custom("SFProText-SemiBold", size: 40))
                .foregroundStyle(Color(hex: "#958787"))
                .padding(.top)
                .padding(.leading)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 50) {
                ForEach(0..<numberOfTasks) { index in
                    Image(systemName: completedTasks > index ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(completedTasks > index ? .green : .gray)
                }
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                onContinue()
            }, label:  {
                Text("Zur \(buttonText) Aufgabe >")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            
            Spacer()
        }
        .padding()
    }
}



#Preview {
    BaseTestView(showCompletedView: .constant(false),
                 indexOfCircle: 0,
                              textOfCircle:"1",destination: {Test1View()}, content: {
        Text("Das ist die Test1View")
    }, explanationContent: {
        Text("Hier sind einige Erklärungen.")
    }, completedContent: { onContinue in
        CompletedView(numberOfTasks: 7, completedTasks: 3, onContinue: onContinue)
    })
}
