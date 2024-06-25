//
//  RadioButtonView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.04.24.
//

import SwiftUI

/// A generic radio Button for the DataInputViews
struct RadioButtonView<T: RadioButtonType>: View {
    @Binding var selectedValue: T
    let value: T
    
    var body: some View {
        Button(action: {
            selectedValue = value
        }) {
            HStack {
                Circle()
                    .foregroundColor(selectedValue == value ? .blue : .gray)
                    .frame(width: 20, height: 20)
                Text(value.displayValue)
            }
        }
        .buttonStyle(.plain)
    }
}

protocol RadioButtonType: Identifiable, Equatable, CaseIterable {
    var displayValue: String { get }
}
