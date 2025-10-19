//
//  TrainingAnalyticsManager.swift
//  DialedIn
//
//  Created by Assistant on 18/10/2025.
//

import Foundation

@Observable
final class TrainingAnalyticsManager {
    private let local: LocalTrainingAnalyticsService
    private let remote: RemoteTrainingAnalyticsService

    // Simple request-level cache matching prior semantics
    private(set) var cachedSnapshot: ProgressSnapshot?
    private var lastCacheTime: Date?
    private let cacheLifetime: TimeInterval = 300
    
    init(services: TrainingAnalyticsServices) {
        self.local = services.local
        self.remote = services.remote
    }
    
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot {
        if let cached = cachedSnapshot,
           let last = lastCacheTime,
           Date().timeIntervalSince(last) < cacheLifetime,
           cached.period == period {
            return cached
        }
        let snapshot = try await local.getProgressSnapshot(for: period)
        cachedSnapshot = snapshot
        lastCacheTime = .now
        return snapshot
    }
    
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component = .weekOfYear) async -> VolumeTrend {
        await local.getVolumeTrend(for: period, interval: interval)
    }
    
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression? {
        try await local.getStrengthProgression(for: exerciseId, in: period)
    }
    
    func invalidateCache() {
        cachedSnapshot = nil
        lastCacheTime = nil
    }
}
