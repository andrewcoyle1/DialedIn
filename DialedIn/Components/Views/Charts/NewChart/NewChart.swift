//
//  NewChart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/09/2026.
//

import SwiftUI
import Charts

struct NewChart: View {
    
    let data = [
        TimeSeries.mock(
            name: "Sample Set 1",
            lowerBound: 5,
            upperBound: 10
        ),
        TimeSeries.mock(
            name: "Sample Set 2",
            lowerBound: 6,
            upperBound: 12
        ),
    ]
    
    var body: some View {
        Chart(data) { series in
            ForEach(series.data, id: \.id) {
                LineMark(
                    x: .value("Day", $0.date, unit: .day),
                    y: .value("Value", $0.value)
                )
            }
            .foregroundStyle(by: .value("Series", series.name))
            .symbol(by: .value("Series", series.name))
        }
        .frame(height: 300)
        .padding()
    }
}

#Preview {
    NewChart()
}
