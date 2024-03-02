//
//  FeedbackView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct FeedbackView: View {
    @State var showNextView: Bool = false
    var body: some View {
        Text("Das ist die FeedbackView")
        Text("Sie können jetzt die App schließen, weil Apple sagt Nein wenn wir die App programatisch schließen :)")
            .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FeedbackView()
}
