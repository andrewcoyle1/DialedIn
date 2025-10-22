//
//  ProgressDashboardViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgressDashboardViewModel {
    private let trainingPlanManager: TrainingPlanManager
    private let trainingAnalyticsManager: TrainingAnalyticsManager
    
    var selectedPeriod: TimePeriod = .lastMonth
    private(set) var progressSnapshot: ProgressSnapshot?
    private(set) var isLoading = false
    
    init(
        container: DependencyContainer
    ) {
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.trainingAnalyticsManager = container.resolve(TrainingAnalyticsManager.self)!
    }
    
    func loadProgressData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await trainingAnalyticsManager.getProgressSnapshot(for: selectedPeriod.dateInterval)
            progressSnapshot = snapshot
        } catch {
            print("Error loading progress: \(error)")
            progressSnapshot = .empty
        }
    }
}
