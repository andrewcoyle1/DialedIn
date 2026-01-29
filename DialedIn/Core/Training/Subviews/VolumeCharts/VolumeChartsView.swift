//
//  VolumeChartsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftfulRouting

struct VolumeChartsView: View {

    @State var presenter: VolumeChartsPresenter

    @ViewBuilder var trendSummarySection: (TrendSummarySectionDelegate) -> AnyView

    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Period picker
                    Picker("Period", selection: $presenter.selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if presenter.isLoading {
                        ProgressView()
                            .padding(40)
                    } else if let trend = presenter.volumeTrend {
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
                        presenter.onDismissPressed()
                    }
                }
            }
            .task {
                await presenter.loadVolumeData()
            }
            .onChange(of: presenter.selectedPeriod) { _, _ in
                Task {
                    await presenter.loadVolumeData()
                }
            }
    }
}

extension CoreBuilder {
    func volumeChartsView(router: AnyRouter) -> some View {
         VolumeChartsView(
            presenter: VolumeChartsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            trendSummarySection: { delegate in
                self.trendSummarySection(delegate: delegate)
                    .any()
            }
         )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.volumeChartsView(router: router)
    }
    .previewEnvironment()
}
