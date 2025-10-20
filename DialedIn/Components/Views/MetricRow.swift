//
//  MetricRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct MetricRow: View {
    let label: String
    let value: String
    let icon: String?
    
    init(label: String, value: String, icon: String? = nil) {
        self.label = label
        self.value = value
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.accent)
                    .frame(width: 20)
            }
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    List {
        MetricRow(label: "Height", value: "175 cm", icon: "ruler")
        MetricRow(label: "Weight", value: "70 kg", icon: "scalemass")
        MetricRow(label: "BMI", value: "22.9")
    }
}
