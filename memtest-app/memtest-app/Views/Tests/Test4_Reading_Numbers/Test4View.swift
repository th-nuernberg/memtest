//
//  Test4View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test4View: View {
    var body: some View {
        BaseTestView(destination: Test5View(), content: {
            Text("Das ist die Test4View")
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
}

#Preview {
    Test4View()
}
