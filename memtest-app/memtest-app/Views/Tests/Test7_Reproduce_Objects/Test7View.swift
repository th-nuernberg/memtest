//
//  Test7View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test7View: View {
    var body: some View {
        BaseTestView(destination: Test8View(), content: {
            Text("Das ist die Test7View")
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
}

#Preview {
    Test7View()
}
