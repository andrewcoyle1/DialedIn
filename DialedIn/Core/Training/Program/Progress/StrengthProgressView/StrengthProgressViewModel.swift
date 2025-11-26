//
//  StrengthProgressViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol StrengthProgressInteractor {
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression?
}

extension CoreInteractor: StrengthProgressInteractor { }

@MainActor
protocol StrengthProgressRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: StrengthProgressRouter { }

@Observable
@MainActor
class StrengthProgressViewModel {
    private let interactor: StrengthProgressInteractor
    private let router: StrengthProgressRouter

    private(set) var strengthMetrics: StrengthMetrics?
    private(set) var isLoading = false
    var selectedPeriod: TimePeriod = .lastThreeMonths
    var selectedExerciseId: String?
    var exerciseProgression: StrengthProgression?

    init(
        interactor: StrengthProgressInteractor,
        router: StrengthProgressRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadStrengthData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await interactor.getProgressSnapshot(for: selectedPeriod.dateInterval)
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
            let progression = try await interactor.getStrengthProgression(
                for: exerciseId,
                in: selectedPeriod.dateInterval
            )
            exerciseProgression = progression
        } catch {
            print("Error loading exercise progression: \(error)")
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}
