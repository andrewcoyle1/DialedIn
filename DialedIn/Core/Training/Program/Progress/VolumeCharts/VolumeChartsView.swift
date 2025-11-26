//
//  VolumeChartsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts
import CustomRouting

struct VolumeChartsView: View {

    @State var viewModel: VolumeChartsViewModel

    @ViewBuilder var trendSummarySection: (TrendSummarySectionDelegate) -> AnyView

    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Period picker
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(40)
                    } else if let trend = viewModel.volumeTrend {
                        VolumeChartSection(trend: trend)
                        trendSummarySection(TrendSummarySectionDelegate(trend: trend))
                    } else {
                        EmptyState()
                    }
                }
                .padding()
            }
            .navigationTitle("Volume Trends")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        viewModel.onDismissPressed()
                    }
                }
            }
            .task {
                await viewModel.loadVolumeData()
            }
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                Task {
                    await viewModel.loadVolumeData()
                }
            }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.volumeChartsView(router: router)
    }
    .previewEnvironment()
}
