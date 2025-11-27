//
//  OverallTargetCellView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

struct OverallTargetCellView: View {
    let metricInitial: String
    let value: Double
    let target: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 0) {
                Text("\(Int(round(value)))")
                if metricInitial == "Cal" {
                    Image(systemName: "flame")
                } else {
                    Text(metricInitial)
                }
            }
            .font(.subheadline)
            .monospacedDigit()
            Text("of \(Int(target))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    OverallTargetCellView(metricInitial: "A", value: 20, target: 50, unit: "g")
}
