//
//  Test8View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test8View: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Text("Das ist die Test8View")
                Button{
                    showNextView.toggle()
                }label: {
                    Text("Zur nächsten View")
                }
                .navigationDestination(isPresented: $showNextView) {
                    TestEndView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    Test8View()
}
