//
//  VolumeChartsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts

struct VolumeChartsView: View {
    @State var viewModel: VolumeChartsViewModel
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
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
                        builder.trendSummarySection(trend: trend)
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
                        dismiss()
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
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.volumeChartsView()
    .previewEnvironment()
}
