//
//  Test7View.swift
//  memtest-app
//
//  Created by Christopher Witzl on 12.04.24.
//

import SwiftUI

struct Test7View: View {
    @State private var finished = false
    
    var body: some View {
        
        BaseTestView(showCompletedView: $finished, indexOfCircle: 6, textOfCircle: "7", destination: { Test8View()}, content: {
            Text("daükop")
        }, explanationContent: {
            Text("Expl")
        },
        completedContent: { onContinue in
            
            CompletedView( completedTasks: 7, onContinue: onContinue)
            
        })
        
    }
}

#Preview {
    Test7View()
}
