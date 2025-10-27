//
//  MacroStatCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct MacroStatCard: View {
    let title: String
    let current: Double
    let target: Double?
    let unit: String
    
    private var percentage: Double? {
        guard let target = target, target > 0 else { return nil }
        return (current / target) * 100
    }
    
    private var progressColor: Color {
        guard let percentage = percentage else { return .blue }
        
        if percentage >= 100 {
            return .green
        } else if percentage >= 75 {
            return .blue
        } else if percentage >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(current))")
                    .font(.title2.bold())
                
                if let target = target {
                    Text("/ \(Int(target))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            if let target = target {
                ProgressView(value: min(current, target), total: target)
                    .tint(progressColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    MacroStatCard(title: "Sample", current: 60, target: 100, unit: "g")
}
