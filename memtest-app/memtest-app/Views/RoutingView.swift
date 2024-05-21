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
    case calibration
    case skt
    case vft
    case bnt
    case pdt
    case feedback
}

struct RoutingView: View {
    var dataService: DataService = DataService.shared
    @State var visibleView: VisibleView = .home
    @State var nextViews: [VisibleView] =  []
    
    var body: some View {
        switch visibleView {
        case .home:
            HomeView { nextView in
                   if (nextView == .skt || nextView == .vft || nextView == .bnt || nextView == .pdt) && dataService.hasQRCodeScanned() && dataService.hasMetadataBeenCollected() && dataService.hasCalibrated() {
                       self.visibleView = nextView
                   } else if !dataService.hasQRCodeScanned() {
                       if !dataService.hasMetadataBeenCollected() {
                           nextViews.append(.metadata)
                           nextViews.append(.calibration)
                           nextViews.append(nextView)
                       }
                       self.visibleView = .welcome
                   } else if !dataService.hasMetadataBeenCollected() {
                       if !dataService.hasQRCodeScanned() {
                           nextViews.append(.welcome)
                           nextViews.append(.calibration)
                           nextViews.append(nextView)
                       } else {
                           nextViews.append(.calibration)
                           nextViews.append(nextView)
                       }
                       self.visibleView = .metadata
                   } else if !dataService.hasCalibrated() {
                       nextViews.append(nextView)
                       self.visibleView = .calibration
                   }
               }
        case .welcome:
            WelcomeRoutingView() {
                self.visibleView = self.nextViews.removeFirst()
            }
        case .metadata:
            DataInputView() {
                self.visibleView = self.nextViews.removeFirst()
            }
        case .calibration:
            CalibrationRoutingView() {
                self.visibleView = self.nextViews.removeFirst()
            }
        case .skt:
            SKTRoutingView() {
                self.visibleView = .home
            }
        case .vft:
            VFTView(){
                self.visibleView = .home
            }
        case .bnt:
            BNTView(){
                self.visibleView = .home
            }
        case .pdt:
            PDTView(){
                self.visibleView = .home
            }
        case .feedback:
            FeedbackView()
        }
    }
    
}

#Preview {
    RoutingView()
}
