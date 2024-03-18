//
//  Test5View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test5View: View {
    var body: some View {
        BaseTestView(destination: Test6View(), content: {
            Text("Das ist die Test5View")
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
}

#Preview {
    Test5View()
}
