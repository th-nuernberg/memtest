//
//  SKTRoutingView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 16.05.24.
//

import SwiftUI

enum SKTViewEnum {
    case skt1
    case skt2
    case learningphase
    case skt3
    case skt4
    case skt5
    case skt6
    case skt7
    case skt8
    case skt9
    case finished
}

/// Routing View for the skt subtests
struct SKTRoutingView: View {
    @State var currentView: SKTViewEnum = .skt1
    
    var onNextView: (() -> Void)?
    
    var body: some View {
        switch currentView {
        case .skt1:
            Test1View(currentView: $currentView)
        case .skt2:
            Test2View(currentView: $currentView)
        case .learningphase:
            LearnphaseView(currentView: $currentView)
        case .skt3:
            Test3View(currentView: $currentView)
        case .skt4:
            Test4View(currentView: $currentView)
        case .skt5:
            Test5View(currentView: $currentView)
        case .skt6:
            Test6View(currentView: $currentView)
        case .skt7:
            Test7View(currentView: $currentView)
        case .skt8:
            Test8View(currentView: $currentView)
        case .skt9:
            Test9View(currentView: $currentView)
        case .finished:
            Text("")
                .onAppear(perform: {
                    onNextView?()
                })
        }
    }
}

#Preview {
    SKTRoutingView()
}
