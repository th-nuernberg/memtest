//
//  CheckboxView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.04.24.
//

import SwiftUI

/// Checkbox that is used in the DataInputViews
struct CheckboxView: View {
    let label: String
    @Binding var isChecked: Bool
    var checkedColor: Color = .blue
    var uncheckedColor: Color = .gray
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? checkedColor : uncheckedColor)
                Text(label)
            }
        }
        .buttonStyle(.plain)
    }
}
