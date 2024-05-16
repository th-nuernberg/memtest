//
//  RoutingView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.05.24.
//

import SwiftUI

enum VisibleView: Equatable {
    case home
    case welcome
    case metadata
    case skt
    case vft
    case bnt
    case pdt
    case feedback
}

struct RoutingView: View {
    var dataService: DataService = DataService.shared
    @State var visibleView: VisibleView = .home
    @State var nextView: VisibleView = .feedback
    
    var body: some View {
        switch visibleView {
        case .home:
            HomeView(){ nextView in
                routeToView(view: nextView)
            }
        case .welcome:
            WelcomeRoutingView() {
                self.visibleView = self.nextView
            }
        case .metadata:
            DataInputView()
        case .skt:
            Test1View()
        case .vft:
            Test10View()
        case .bnt:
            Test11View()
        case .pdt:
            Test12View()
        case .feedback:
            FeedbackView()
        }
    }
    
    func routeToView(view: VisibleView) {
        if (view == .skt || view == .vft || view == .bnt || view == .pdt) && dataService.hasQRCodeScanned() {
            self.visibleView = view
        } else if (dataService.hasMetadataBeenCollected()) {
            
        } else  {
            self.visibleView = .welcome
            self.nextView = view
        }
    }
}

#Preview {
    RoutingView()
}
