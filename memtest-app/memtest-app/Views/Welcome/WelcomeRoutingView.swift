//
//  WelcomeRoutingView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 15.05.24.
//

import SwiftUI

enum WelcomeViewEnum {
    case welcome
    case welcomeStudy
    case next
}

struct WelcomeRoutingView: View {
    @State var visibleView: WelcomeViewEnum = .welcome
    var onNextView: (() -> Void)
    
    var body: some View {
        if(visibleView == .welcome) {
            WelcomeView(){ view in
                self.visibleView = view
            }
        } else if (visibleView == .welcomeStudy) {
            WelcomeStudyView(){ view in
                onNextView()
            }
        }
    }
}

#Preview {
    WelcomeRoutingView(){
        
    }
}
