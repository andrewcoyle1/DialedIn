//
//  VolumeChartsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol VolumeChartsInteractor {
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component) async -> VolumeTrend
}

extension CoreInteractor: VolumeChartsInteractor { }

@Observable
@MainActor
class VolumeChartsViewModel {
    private let interactor: VolumeChartsInteractor
    
    private(set) var volumeTrend: VolumeTrend?
    private(set) var isLoading = false
    var selectedPeriod: TimePeriod = .lastMonth

    init(
        interactor: VolumeChartsInteractor
    ) {
        self.interactor = interactor
    }
    
    func loadVolumeData() async {
        isLoading = true
        defer { isLoading = false }
        let trend = await interactor.getVolumeTrend(
            for: selectedPeriod.dateInterval,
            interval: .weekOfYear
        )
        volumeTrend = trend
    }
}
