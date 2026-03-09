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
    let value: Binding<Double?>
    let unit: T
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            TextFieldwUnit<T>(value: value, unit: unit)
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
    let value: Binding<Double?>
    let unit: Binding<T>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            TextFieldwUnitPicker<T>(value: value, unit: unit)
                .background(colorScheme.backgroundPrimary, in: .containerRelative)
        }
    }
}

#Preview {
    @Previewable @State var value: Double?
    @Previewable @State var unit: NutritionWeightUnit = .grams
    
    List {
        LabeledTextFieldWithUnit(label: "Weight", value: $value, unit: unit)
        LabeledTextFieldWithUnitPicker(label: "Weight", value: $value, unit: $unit)
    }
}
