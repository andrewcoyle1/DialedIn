//
//  MultipleSelectionRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    List {
        MultipleSelectionRow(
            title: "Chest",
            isSelected: true
        ) {
            // Action
        }
        
        MultipleSelectionRow(
            title: "Back",
            isSelected: false
        ) {
            // Action
        }
    }
}
