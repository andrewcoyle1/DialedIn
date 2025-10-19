//
//  StatBadge.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct StatBadge: View {
    let value: String
    let label: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(value)
                    .font(.headline)
            }
            .foregroundStyle(color)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StatBadge(
        value: "Value",
        label: "Label",
        systemImage: "dumbbell",
        color: .red
    )
}
