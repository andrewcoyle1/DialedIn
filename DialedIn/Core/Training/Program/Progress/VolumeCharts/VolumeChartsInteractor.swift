//
//  VolumeChartsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol VolumeChartsInteractor {
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component) async -> VolumeTrend
}

extension CoreInteractor: VolumeChartsInteractor { }
