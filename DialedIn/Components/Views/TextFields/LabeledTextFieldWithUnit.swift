//
//  LabeledTextFieldWithUnit.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/03/2026.
//

import SwiftUI

struct LabeledTextField: View {
        
    let label: String
    var prompt: String = ""
    let text: Binding<String>
    
    var body: some View {
        Section {
            TextField(prompt, text: text)
        } header: {
            Text(label)
        }
    }
}

struct LabeledTextFieldWithUnit<T: PickableUnit>: View {
        
    let label: String
    var prompt: String = ""
    let value: Binding<Double?>
    let unit: T
    
    var body: some View {
        Section {
            TextFieldwUnit<T>(prompt: prompt, value: value, unit: unit)
        } header: {
            Text(label)
        }
    }
}

struct LabeledTextFieldWithUnitPicker<T: PickableUnit>: View {
        
    let label: String
    let value: Binding<Double?>
    let unit: Binding<T>
    
    var body: some View {
        Section {
            TextFieldwUnitPicker<T>(value: value, unit: unit)
        } header: {
            Text(label)
        }
    }
}

#Preview {
    @Previewable @State var value: Double?
    @Previewable @State var unit: NutritionWeightUnit = .grams
    
    List {
        LabeledTextFieldWithUnit(label: "Weight", value: $value, unit: unit)
        LabeledTextFieldWithUnitPicker(label: "Weight", value: $value, unit: $unit)
        LabeledTextField(
            label: "Labelled Text Field",
            prompt: "Labelled Text Field Prompt",
            text: .constant("")
        )
    }
}
