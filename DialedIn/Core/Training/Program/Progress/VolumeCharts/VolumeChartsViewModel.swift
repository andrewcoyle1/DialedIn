//
//  VolumeChartsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class VolumeChartsViewModel {
    private let trainingAnalyticsManager: TrainingAnalyticsManager
    
    private(set) var volumeTrend: VolumeTrend?
    private(set) var isLoading = false
    var selectedPeriod: TimePeriod = .lastMonth

    init(
        container: DependencyContainer
    ) {
        self.trainingAnalyticsManager = container.resolve(TrainingAnalyticsManager.self)!
    }
    
    func loadVolumeData() async {
        isLoading = true
        defer { isLoading = false }
        let trend = await trainingAnalyticsManager.getVolumeTrend(
            for: selectedPeriod.dateInterval,
            interval: .weekOfYear
        )
        volumeTrend = trend
    }
}
