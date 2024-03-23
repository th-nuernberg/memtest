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
        self._showExplanation = State(initialValue: self.explanationContent() != nil)
    }
    
    var body: some View {
        NavigationStack {
            if showExplanation, let explanation = explanationContent() {
                ExplanationView(content: { explanation }, onContinue: {
                    showExplanation = false
                })
            } else {
                VStack {
                    content()
                }            }
        }
        .navigationBarBackButtonHidden(true)
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


#Preview {
    BaseTestView(destination: Test1View(), content: {
        Text("Das ist die Test1View")
    }, explanationContent: {
        Text("Hier sind einige Erklärungen.")
    })
}
