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

struct CalibrationRoutingView: View {
    @State var visibleView: CalibrationViewEnum = .dragDropCalibration
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
