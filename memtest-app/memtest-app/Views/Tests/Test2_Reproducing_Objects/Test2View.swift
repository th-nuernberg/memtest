//
//  Test2View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test2View: View {
    var body: some View {
        BaseTestView(destination: Test3View(), content: {
            Text("Das ist die Test2View")
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
}

#Preview {
    Test2View()
}
