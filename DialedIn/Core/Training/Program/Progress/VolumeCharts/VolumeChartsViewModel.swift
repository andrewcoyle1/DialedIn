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

@MainActor
protocol VolumeChartsRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: VolumeChartsRouter { }

@Observable
@MainActor
class VolumeChartsViewModel {
    private let interactor: VolumeChartsInteractor
    private let router: VolumeChartsRouter

    private(set) var volumeTrend: VolumeTrend?
    private(set) var isLoading = false
    var selectedPeriod: TimePeriod = .lastMonth

    init(
        interactor: VolumeChartsInteractor,
        router: VolumeChartsRouter
    ) {
        self.interactor = interactor
        self.router = router
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

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}
