//
//  Test6View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test6View: View {
    var body: some View {
        BaseTestView(destination: Test7View(), content: {
            Text("Das ist die Test6View")
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
}

#Preview {
    Test6View()
}
