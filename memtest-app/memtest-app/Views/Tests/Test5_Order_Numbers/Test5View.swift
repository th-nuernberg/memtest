//
//  Test5View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test5View: View {
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                Text("Das ist die Test5View")
                Button{
                    showNextView.toggle()
                }label: {
                    Text("Zur nächsten View")
                }
                .navigationDestination(isPresented: $showNextView) {
                    Test6View()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    Test5View()
}
