//
//  AutoSelectNumberField.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/03/2026.
//

import SwiftUI

struct AutoSelectNumberField: View {
    
    @FocusState private var isFocused
    @State private var selection: TextSelection?
    @State private var text: String = ""

    var prompt: String
    @Binding var value: Double?
    let textAlignment: TextAlignment
    let keyboardType: UIKeyboardType
    
    init(
        prompt: String,
        value: Binding<Double?>,
        alignment: TextAlignment = .center,
        keyboardType: UIKeyboardType = .decimalPad
    ) {
        self.prompt = prompt
        self._value = value
        self.textAlignment = alignment
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        TextField(prompt, text: $text, selection: $selection)
            .focused($isFocused)
            .multilineTextAlignment(textAlignment)
            .onChange(of: text) { _, newValue in
                value = Double(newValue)
            }
            .onChange(of: isFocused) { _, focused in
                if focused {
                    selection = .init(range: text.startIndex..<text.endIndex)
                }
            }
            .onAppear {
                text = value.map(\.description) ?? ""
            }
            .keyboardType(keyboardType)
    }
}

#Preview {
    @Previewable @State var value: Double?
    List {
        AutoSelectNumberField(prompt: "0.0", value: $value)
//            .textFieldStyle(.roundedBorder)
    }
}
