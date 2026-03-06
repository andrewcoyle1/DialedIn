//
//  StatCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/10/2025.
//

import SwiftUI

struct StatCard: View {
    let value: String
    let label: String
    let icon: String?
    let color: Color?
    let alignment: HorizontalAlignment
    
    init(
        value: String,
        label: String,
        icon: String? = nil,
        color: Color? = nil,
        alignment: HorizontalAlignment = .leading
    ) {
        self.value = value
        self.label = label
        self.icon = icon
        self.color = color
        self.alignment = alignment
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            if let icon {
                if let color {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                    
                }
            }
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    StatCard(
        value: "Value",
        label: "Label",
        icon: "dumbbell",
        color: .red
    )
}
