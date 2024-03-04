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
        QRCodeView()
    }
}

#Preview {
    ContentView()
}
