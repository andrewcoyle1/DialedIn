//
//  TrainingProgressChartsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI
import CustomRouting

struct TrainingProgressChartsView: View {
    
    @State var presenter: TrainingProgressChartsPresenter
    
    var body: some View {
        Section(isExpanded: $presenter.isExpanded) {
            Button {
                presenter.onProgressAnalyticsPressed()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("View Progress Analytics")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        Text("Track volume, strength, and performance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 8)
            }
            HistoryChart(series: TimeSeriesData.last30Days)
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Activity")
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(presenter.isExpanded ? 0 : 90))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                presenter.onExpandedToggle()
            }
            .animation(.easeInOut, value: presenter.isExpanded)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    
    RouterView { router in
        builder.trainingProgressChartsView(router: router)
    }
}
