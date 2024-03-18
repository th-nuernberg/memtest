//
//  Test1View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test1View: View {
    var body: some View {
        BaseTestView(destination: Test2View(), content: {
            Text("Das ist die Test1View")
        }, explanationContent: {
            Text("Hier sind einige Erklärungen.")
        })
    }
}


#Preview {
    Test1View()
}
