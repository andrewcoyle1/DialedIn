//
//  DashboardCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/02/2026.
//

import SwiftUI

struct DashboardCardChartConfiguration {
    var height: CGFloat = 44
    var verticalPadding: CGFloat = 4
}

struct DashboardCard<MetricChart: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var title: String?
    var subtitle: String?
    var subsubtitle: String?
    var subsubsubtitle: String?
    var chartConfiguration: DashboardCardChartConfiguration
    var chart: () -> MetricChart
    
    init(
        title: String? = "Title",
        subtitle: String? = "Subtitle",
        subsubtitle: String? = "Subsubtitle",
        subsubsubtitle: String? = "Subsubsubtitle",
        chartConfiguration: DashboardCardChartConfiguration = DashboardCardChartConfiguration(),
        chart: @escaping () -> MetricChart = {
            ContributionChartView(
                data: [0, 0.1, 0.3, 0.5, 0.7, 0.9],
                rows: 3,
                columns: 10,
                targetValue: 1,
                blockColor: .red,
                rectangleWidth: .infinity,
                endDate: .now,
                showsCaptioning: false
            )
        }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subsubtitle = subsubtitle
        self.subsubsubtitle = subsubsubtitle
        self.chartConfiguration = chartConfiguration
        self.chart = chart
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .lineLimit(1)
            }
            
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
                
            Spacer()
            
            chart()
                .frame(maxWidth: .infinity, maxHeight: chartConfiguration.height)
                .padding(.vertical, chartConfiguration.verticalPadding)

            Spacer()

            HStack {
                HStack(alignment: .firstTextBaseline) {
                    if let subsubtitle {
                        Text(subsubtitle)
                            .lineLimit(1)
                            .font(.caption)
                        
                    }
                    if let subsubsubtitle {
                        Text(subsubsubtitle)
                            .lineLimit(1)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .frame(height: 120)
        .padding()
        .background(colorScheme.backgroundPrimary)
        .cornerRadius(16)
    }
    
}

#Preview {
    List {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard()
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        }
        .listSectionMargins(.horizontal, 0)
    }
}
