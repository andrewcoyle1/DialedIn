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
                // A decimal pad carries no letters, but a hardware keyboard, a paste or dictation
                // can still put "nan" or "inf" into the field, and `Double`'s string initialiser
                // parses both literally. Everything downstream of this field multiplies the value
                // into arithmetic that is printed through `Int(_:)`, which traps on a value that
                // is not finite — so a number that is not a number never leaves the field.
                value = Double(newValue).flatMap { $0.isFinite ? $0 : nil }
            }
            .onChange(of: isFocused) { _, focused in
                if focused {
                    selection = .init(range: text.startIndex..<text.endIndex)
                }
            }
            .onChange(of: value) { _, newValue in
                if !isFocused {
                    text = newValue.map(\.description) ?? ""
                }
            }
            .onAppear {
                text = value.map(\.description) ?? ""
            }
            .keyboardType(keyboardType)
    }
}

#Preview {
    @Previewable @State var value: Double? = 20
    List {
        AutoSelectNumberField(prompt: "0.0", value: $value)
//            .textFieldStyle(.roundedBorder)
    }
}
