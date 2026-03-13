//
//  TextFieldwUnitPicker.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/03/2026.
//

import SwiftUI

protocol PickableUnit: CaseIterable, Hashable where AllCases: RandomAccessCollection {
    var id: String { get }
    var acronym: String { get }
}

struct TextFieldwUnitPicker<T: PickableUnit & CaseIterable>: View {  // Add CaseIterable if needed for allCases
    
    @FocusState private var isFocused
    @State private var selection: TextSelection?
    @State private var text: String = ""
    
    var prompt: String = ""
    @Binding var value: Double?
    @Binding var unit: T
    
    var body: some View {
        HStack {
            AutoSelectNumberField(prompt: prompt, value: $value, alignment: .leading)
                .textFieldStyle(.plain)
                .padding(.trailing, -16)
            Picker("", selection: $unit) {
                ForEach(Array(T.allCases), id: \.id) { unitValue in  // Renamed for clarity
                    Text(unitValue.acronym)
                        .tag(unitValue)
                }
            }
            .frame(width: 60)
        }
    }
}

#Preview {
    @Previewable @State var value: Double?
    @Previewable @State var unit: NutritionWeightUnit = .grams
    
    List {
        DisclosureGroup {
            TextFieldwUnitPicker<NutritionWeightUnit>(prompt: "Prompt", value: $value, unit: $unit)
        } label: {
            Text("Label")
        }
    }
}
