//
//  TestEndView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct TestEndView: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Text("Das ist die TestEndView")
                Button{
                    showNextView.toggle()
                }label: {
                    Text("Zur nächsten View")
                }
                .navigationDestination(isPresented: $showNextView) {
                    FeedbackView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    TestEndView()
}
