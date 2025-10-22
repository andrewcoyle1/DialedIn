//
//  StrengthProgressViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class StrengthProgressViewModel {
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let trainingAnalyticsManager: TrainingAnalyticsManager
    
    private(set) var strengthMetrics: StrengthMetrics?
    private(set) var isLoading = false
    var selectedPeriod: TimePeriod = .lastThreeMonths
    var selectedExerciseId: String?
    var exerciseProgression: StrengthProgression?

    init(
        container: DependencyContainer
    ) {
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.trainingAnalyticsManager = container.resolve(TrainingAnalyticsManager.self)!
    }
    
    func loadStrengthData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await trainingAnalyticsManager.getProgressSnapshot(for: selectedPeriod.dateInterval)
            strengthMetrics = snapshot.strengthMetrics
            
            // Auto-select first PR if available
            if let firstPR = snapshot.strengthMetrics.personalRecords.first {
                selectedExerciseId = firstPR.exerciseId
            }
        } catch {
            print("Error loading strength data: \(error)")
        }
    }
    
    func loadExerciseProgression(_ exerciseId: String) async {
        do {
            let progression = try await trainingAnalyticsManager.getStrengthProgression(
                for: exerciseId,
                in: selectedPeriod.dateInterval
            )
            exerciseProgression = progression
        } catch {
            print("Error loading exercise progression: \(error)")
        }
    }
}
