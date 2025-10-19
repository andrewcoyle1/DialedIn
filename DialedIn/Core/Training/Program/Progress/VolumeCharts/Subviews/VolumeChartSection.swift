//
//  VolumeChartSection.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts

struct VolumeChartSection: View {
    
    let trend: VolumeTrend
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Volume Over Time")
                .font(.headline)
            
            if !trend.dataPoints.isEmpty {
                Chart(trend.dataPoints) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Volume", dataPoint.volume)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                    
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Volume", dataPoint.volume)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue.opacity(0.2))
                    
                    PointMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Volume", dataPoint.volume)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 250)
                .chartYAxisLabel("Volume (kg)")
                .chartXAxis {
                    AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
            } else {
                Text("No volume data available for this period")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    List {
        VolumeChartSection(trend: VolumeTrend.mock)
    }
    .previewEnvironment()
}
