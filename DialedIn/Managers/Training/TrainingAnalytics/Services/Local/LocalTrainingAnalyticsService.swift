//
//  LocalTrainingAnalyticsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

protocol LocalTrainingAnalyticsService {
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component) async -> VolumeTrend
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression?
}
