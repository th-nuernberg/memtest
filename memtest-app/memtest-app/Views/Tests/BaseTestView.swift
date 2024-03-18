//
//  BaseTestView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 15.03.24.
//

import SwiftUI

struct BaseTestView<Destination: View, Content: View, ExplanationContent: View>: View {
    let destination: Destination
    let content: () -> Content
    var explanationContent: () -> ExplanationContent?
    @State private var showNextView = false
    @State private var showExplanation: Bool

    init(destination: Destination, @ViewBuilder content: @escaping () -> Content, @ViewBuilder explanationContent: @escaping () -> ExplanationContent? = { nil }) {
        self.destination = destination
        self.content = content
        self.explanationContent = explanationContent
        // Initialize showExplanation based on whether explanationContent is not nil
        self._showExplanation = State(initialValue: self.explanationContent() != nil)
    }

    var body: some View {
        NavigationStack {
            // Conditional View based on whether to show explanation or content
            if showExplanation, let explanation = explanationContent() {
                // Show explanation view with a continue button
                ExplanationView(content: { explanation }, onContinue: {
                    // When continue is tapped, hide explanation and show content or navigate
                    showExplanation = false
                })
            } else {
                // Main content view
                VStack {
                    content()
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showExplanation = true
                        }) {
                            Text("Zurück")
                                .padding()
                                .background(.tBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showNextView = true
                        }) {
                            Text("Weiter")
                                .padding()
                                .background(.tBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $showNextView) {
                            destination
                        }
                        .navigationBarBackButtonHidden(true)
                    }
                }
                .padding()
            }
        }
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
            HStack {
                Spacer()
                Button(action: onContinue) {
                    Text("Weiter")
                        .padding()
                        .background(.tBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}


#Preview {
    BaseTestView(destination: Test2View(), content: {
        Text("Das ist die Test1View")
    }, explanationContent: {
        Text("Hier sind einige Erklärungen.")
    })
}
