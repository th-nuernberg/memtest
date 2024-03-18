//
//  Test3View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test3View: View {
    var body: some View {
        BaseTestView(destination: Test4View(), content: {
            Text("Das ist die Test3View")
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
}

#Preview {
    Test3View()
}
