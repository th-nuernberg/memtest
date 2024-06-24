//
//  CalibrationRoutingView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 18.05.24.
//

import SwiftUI

enum  CalibrationViewEnum {
    case dragDropCalibration
    case audioCalibration
}

// View for routing between the DragNDropCalibrationView and the AudioCalibrationView
// there should be a better way to route
struct CalibrationRoutingView: View {
    @State var visibleView: CalibrationViewEnum = .dragDropCalibration
    // callback for signaling that the calibration is finished
    var onNextView: (() -> Void)
    
    var body: some View {
        switch self.visibleView {
        case .dragDropCalibration:
            DragDropCalibrationView(){
                self.visibleView = .audioCalibration
            }
        case .audioCalibration:
            AudioCalibrationView{
                DataService.shared.setCalibrated(calibrated: true)
                print(DataService.shared.hasCalibrated())
                onNextView()
            }
        }
    }
}

#Preview {
    CalibrationRoutingView(){
        
    }
}
