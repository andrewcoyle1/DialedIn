//
//  TextFieldwUnit.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/03/2026.
//

import SwiftUI

struct TextFieldwUnit<T: PickableUnit>: View {
    
    @FocusState private var isFocused
    @State private var selection: TextSelection?
    @State private var text: String = ""

    var prompt: String = ""
    @Binding var value: Double?
    var unit: T
    
    var body: some View {
        HStack {
            AutoSelectNumberField(prompt: prompt, value: $value, alignment: .leading)
                .textFieldStyle(.roundedBorder)
            Text(unit.acronym)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    @Previewable @State var value: Double?
    let unit: NutritionWeightUnit = .grams
    
    List {
        DisclosureGroup {
            TextFieldwUnit<NutritionWeightUnit>(prompt: "Prompt", value: $value, unit: unit)
        } label: {
            Text("Label")
        }
    }
}
