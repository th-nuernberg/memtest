//
//  BaseTestView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 15.03.24.
//

import SwiftUI

struct BaseTestView<Destination: View, Content: View, ExplanationContent: View, CompletedContent: View>: View {
    let destination: () -> Destination
    let content: () -> Content
    var explanationContent: () -> ExplanationContent?
    var completedContent: () -> CompletedContent?
    @Binding private var showCompletedView: Bool
    @State var showNextView: Bool = false
    @State private var showExplanation: Bool
    
    
    init(showCompletedView: Binding<Bool>, destination: @escaping () -> Destination, @ViewBuilder content: @escaping () -> Content, @ViewBuilder explanationContent: @escaping () -> ExplanationContent? = { nil }, @ViewBuilder completedContent: @escaping () -> CompletedContent? = { nil }) {
        self.destination = destination
        self.content = content
        self.explanationContent = explanationContent
        self.completedContent = completedContent
        self._showExplanation = State(initialValue: self.explanationContent() != nil)
        self._showCompletedView = showCompletedView
    }
    
    var body: some View {
        NavigationStack {
            if showExplanation, let explanation = explanationContent() {
                ExplanationView(content: { explanation }, onContinue: {
                    showExplanation = false
                })
            } else {
                VStack {
                    if (showCompletedView == false) {
                        content()
                    } else {
                        completedContent()
                        // CompletedView
                        Text("Completed")
                        Button("Weiter") {
                            showNextView = true
                        }
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
    
    init(@ViewBuilder content: () -> Content, onContinue: @escaping () -> Void) {
        self.content = content()
        self.onContinue = onContinue
    }
    
    var body: some View {
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
            
            NavigationLink(destination: Test2View()) {
                Text("Zur \(buttonText) Aufgabe >")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}



#Preview {
    BaseTestView(showCompletedView: .constant(false) ,destination: {Test1View()}, content: {
        Text("Das ist die Test1View")
    }, explanationContent: {
        Text("Hier sind einige Erklärungen.")
    }, completedContent: {
        Text("Completed")
    })
}
