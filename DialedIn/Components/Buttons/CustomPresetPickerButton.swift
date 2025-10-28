//
//  CustomPresetPickerButton.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct CustomPresetPicker: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                CustomPresetPickerButton(value: option, pickedValue: $selected)
            }
        }
    }
}

struct CustomPresetPickerButton: View {
    
    var value: String
    @Binding var pickedValue: String
    
    var body: some View {
        Button {
            onTap(value: value)
        } label: {
            Text(value)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .background(value == pickedValue ? Color.accentColor.opacity(0.2) : Color.clear)
        .animation(.easeInOut, value: pickedValue)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(value == pickedValue ? Color.accentColor : Color.gray.opacity(0.5), lineWidth: 1)
        )
        .animation(.easeInOut, value: pickedValue)
    }
    
    private func onTap(value: String) {
        withAnimation(.easeInOut) {
            pickedValue = value
        }
    }
}

#Preview("Single Button") {
    CustomPresetPickerButton(value: "10", pickedValue: Binding.constant("10"))
        .frame(maxWidth: 50)
}

struct PreviewWrapper: View {
    @State private var selected = "10"
    var body: some View {
        CustomPresetPicker(options: ["5", "10", "15", "20"], selected: $selected)
            .padding()
    }
}

#Preview("Picker") {
   
    PreviewWrapper()
}
