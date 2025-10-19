//
//  VolumeChartsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Charts

struct VolumeChartsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TrainingAnalyticsManager.self) private var trainingAnalytics
    @State private var volumeTrend: VolumeTrend?
    @State private var isLoading = false
    @State private var selectedPeriod: TimePeriod = .lastMonth
    
    init() {}
    
    enum TimePeriod: String, CaseIterable {
        case lastMonth = "Month"
        case lastThreeMonths = "3 Months"
        case lastSixMonths = "6 Months"
        
        var dateInterval: DateInterval {
            let now = Date()
            let calendar = Calendar.current
            
            switch self {
            case .lastMonth:
                let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return DateInterval(start: start, end: now)
            case .lastThreeMonths:
                let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
                return DateInterval(start: start, end: now)
            case .lastSixMonths:
                let start = calendar.date(byAdding: .month, value: -6, to: now) ?? now
                return DateInterval(start: start, end: now)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period picker
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView()
                            .padding(40)
                    } else if let trend = volumeTrend {
                        VolumeChartSection(trend: trend)
                        TrendSummarySection(trend: trend)
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
                await loadVolumeData()
            }
            .onChange(of: selectedPeriod) { _, _ in
                Task {
                    await loadVolumeData()
                }
            }
        }
    }
    
    private func loadVolumeData() async {
        isLoading = true
        defer { isLoading = false }
        let trend = await trainingAnalytics.getVolumeTrend(
            for: selectedPeriod.dateInterval,
            interval: .weekOfYear
        )
        volumeTrend = trend
    }
}

#Preview {
    return VolumeChartsView()
        .previewEnvironment()
}
