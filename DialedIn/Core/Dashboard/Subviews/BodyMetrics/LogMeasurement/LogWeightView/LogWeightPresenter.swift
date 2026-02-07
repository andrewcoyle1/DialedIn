//
//  LogWeightPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class LogWeightPresenter {
    private let interactor: LogWeightInteractor
    private let router: LogWeightRouter

    var selectedDate = Date()
    var selectedKilograms: Int = 70
    var selectedPounds: Int = 154
    var notes: String = ""
    var unit: UnitOfWeight = .kilograms
    var isLoading: Bool = false

    private var weightKg: Double {
        switch unit {
        case .kilograms:
            return Double(selectedKilograms)
        case .pounds:
            return Double(selectedPounds) * 0.453592
        }
    }

    var weightHistory: [BodyMeasurementEntry] {
        interactor.measurementHistory
    }

    init(
        interactor: LogWeightInteractor,
        router: LogWeightRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func loadInitialData() async {
        guard let user = interactor.currentUser else { return }

        // Set initial unit based on user preference
        if let preference = user.weightUnitPreference {
            unit = preference == .kilograms ? .kilograms : .pounds
        }

        // Set initial weight to current weight if available
        if let currentWeight = user.weightKilograms {
            selectedKilograms = Int(currentWeight)
            selectedPounds = Int(currentWeight * 2.20462)
        }

        // Load recent entries
        _ = try? await interactor.readAllRemoteWeightEntries(userId: user.userId)
    }

    func saveWeight() async {
        guard let user = interactor.currentUser else { return }

        isLoading = true

        do {
            // Save weight entry
            let entry = BodyMeasurementEntry(authorId: user.userId, weightKg: weightKg, date: selectedDate)
            try await interactor.createWeightEntry(weightEntry: entry)

            // Update user's current weight
            try await interactor.updateWeight(userId: user.userId, weightKg: weightKg)

            // Success haptic feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif

            router.dismissScreen()
        } catch {
            router.showAlert(error: error)
        }

        isLoading = false
    }

    func formatWeight(_ weightKg: Double?) -> String {
        guard let weightKg else { return "--" }
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}

enum UnitOfWeight {
    case kilograms
    case pounds
}
