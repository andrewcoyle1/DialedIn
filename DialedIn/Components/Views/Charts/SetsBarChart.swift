//
//  SetsBarChart.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

/// A simple bar chart showing sets per day (e.g. last 7 days).
/// Each day is one vertical bar; bars are scaled to the max value and use a single color.
struct SetsBarChart: View {
    var data: [Double]
    var color: Color = .blue

    private let barSpacing: CGFloat = 3
    private let cornerRadius: CGFloat = 3

    /// Max value across all days for scaling
    private var maxValue: Double {
        data.max() ?? 1
    }

    var body: some View {
        GeometryReader { geo in
            let barWidth = max(4, (geo.size.width - barSpacing * CGFloat(max(0, data.count - 1))) / CGFloat(max(1, data.count)))

            HStack(alignment: .bottom, spacing: barSpacing) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, value in
                    dayBar(value: value, maxHeight: geo.size.height, barWidth: barWidth)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func dayBar(value: Double, maxHeight: CGFloat, barWidth: CGFloat) -> some View {
        let barHeight: CGFloat = {
            guard maxValue > 0 else { return 0 }
            if value <= 0 { return 4 }
            return max(4, maxHeight * (value / maxValue))
        }()

        VStack(spacing: 0) {
            Spacer(minLength: 0)
            if value > 0 {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .frame(height: max(1, barHeight))
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
            }
        }
        .frame(width: barWidth, height: maxHeight)
    }
}

#Preview("With data") {
    SetsBarChart(data: [0, 3, 6, 4, 8, 5, 2], color: .blue)
        .frame(height: 36)
        .padding()
}

#Preview("Empty") {
    SetsBarChart(data: Array(repeating: 0, count: 7), color: .blue)
        .frame(height: 36)
        .padding()
}
