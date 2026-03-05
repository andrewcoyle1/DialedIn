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

struct TextFieldwUnitPicker<T: PickableUnit>: View {
    
    var prompt: String = ""
    @Binding var text: String
    @Binding var unit: T
    
    var body: some View {
        Picker(selection: $unit) {
            ForEach(Array(T.allCases), id: \.id) { value in
                Text(value.acronym)
                    .tag(value)
            }
        } label: {
            TextField(prompt, text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.trailing, -16)
        }
    }
}

struct TextFieldwUnit<T: PickableUnit>: View {
    
    var prompt: String = ""
    @Binding var text: String
    var unit: T

    var body: some View {
        HStack {
            TextField(prompt, text: $text)
                .textFieldStyle(.roundedBorder)
            Text(unit.acronym)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    @Previewable @State var unit: UnitOfWeight = .kilograms
    List {
        Group {
            TextFieldwUnitPicker<UnitOfWeight>(text: $text, unit: $unit)
            TextFieldwUnitPicker<UnitOfWeight>(text: $text, unit: $unit)
            TextFieldwUnit<UnitOfWeight>(text: $text, unit: unit)
            TextFieldwUnit<UnitOfWeight>(text: $text, unit: unit)
            TextFieldwUnitPicker<UnitOfWeight>(text: $text, unit: $unit)
            TextFieldwUnit<UnitOfWeight>(text: $text, unit: unit)
            TextFieldwUnitPicker<UnitOfWeight>(text: $text, unit: $unit)
            TextFieldwUnit<UnitOfWeight>(text: $text, unit: unit)
            TextFieldwUnitPicker<UnitOfWeight>(text: $text, unit: $unit)
            TextFieldwUnit<UnitOfWeight>(text: $text, unit: unit)
        }
        .listRowSeparator(.hidden)
    }
}
