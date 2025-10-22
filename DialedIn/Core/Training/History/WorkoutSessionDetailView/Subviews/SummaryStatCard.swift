//
//  SummaryStatCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/10/2025.
//

import SwiftUI

struct SummaryStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SummaryStatCard(
        value: "Value",
        label: "Label",
        icon: "dumbbell",
        color: .red
    )
}
