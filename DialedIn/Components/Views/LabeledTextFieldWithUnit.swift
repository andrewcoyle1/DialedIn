//
//  LabeledTextFieldWithUnit.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/03/2026.
//

import SwiftUI

struct LabeledTextFieldWithUnit<T: PickableUnit>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let label: String
    let text: Binding<String>
    let unit: T
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            TextFieldwUnit<T>(text: text, unit: unit)
                .background(colorScheme.backgroundPrimary, in: .containerRelative)
        }
    }
    
    static func == (lhs: LabeledTextFieldWithUnit, rhs: LabeledTextFieldWithUnit) -> Bool {
        lhs.label == rhs.label
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }

}

struct LabeledTextFieldWithUnitPicker<T: PickableUnit>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let label: String
    let text: Binding<String>
    let unit: Binding<T>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            TextFieldwUnitPicker<T>(text: text, unit: unit)
                .background(colorScheme.backgroundPrimary, in: .containerRelative)
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    @Previewable @State var unit: NutritionWeightUnit = .grams
    
    List {
        LabeledTextFieldWithUnit(label: "Weight", text: $text, unit: unit)
        LabeledTextFieldWithUnitPicker(label: "Weight", text: $text, unit: $unit)
    }
}
