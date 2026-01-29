//
//  VolumeChartsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class VolumeChartsPresenter {
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
