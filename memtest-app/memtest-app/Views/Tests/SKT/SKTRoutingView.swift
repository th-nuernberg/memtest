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
}

struct SKTRoutingView: View {
    @State var currentView: SKTViewEnum = .skt1
    
    var onNextView: (() -> Void)?
    
    var body: some View {
        switch currentView {
        case .skt1:
            Test1View(currentView: $currentView)
        case .skt2:
            Test2View()
        case .learningphase:
            LearnphaseView()
        case .skt3:
            Test3View()
        case .skt4:
            Test4View()
        case .skt5:
            Test5View()
        case .skt6:
            Test6View()
        case .skt7:
            Test7View()
        case .skt8:
            Test9View()
        case .skt9:
            Test9View()
        }
    }
}

#Preview {
    SKTRoutingView()
}
