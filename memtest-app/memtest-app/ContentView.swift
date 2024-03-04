//
//  ContentView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 22.02.24.
//

import SwiftUI

struct ContentView: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Text("Das ist die ContentView")
                Button{
                    showNextView.toggle()
                }label: {
                    Text("Zur nächsten View")
                }
                .navigationDestination(isPresented: $showNextView) {
                    QRCodeInputView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    ContentView()
}
