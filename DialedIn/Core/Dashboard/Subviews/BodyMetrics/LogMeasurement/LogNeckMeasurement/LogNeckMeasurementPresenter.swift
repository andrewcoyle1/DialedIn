//
//  LogNeckMeasurementPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI

@Observable
@MainActor
class LogNeckMeasurementPresenter {
    private let interactor: LogNeckMeasurementInteractor
    private let router: LogNeckMeasurementRouter

    var selectedDate = Date()
    var selectedCentimeters: Int = 40
    var selectedInches: Int = 16
    var unit: UnitOfLength = .centimeters
    var isLoading: Bool = false

    private var measurementCm: Double {
        switch unit {
        case .centimeters:
            return Double(selectedCentimeters)
        case .inches:
            return Double(selectedInches) * 2.54
        }
    }

    init(
        interactor: LogNeckMeasurementInteractor,
        router: LogNeckMeasurementRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func loadInitialData() async {
        guard let user = interactor.currentUser else { return }

        // Set initial unit based on user preference
        if let preference = user.lengthUnitPreference {
            unit = preference == .centimeters ? .centimeters : .inches
        }

        // Set initial measurement from latest entry if available
        if let latest = interactor.measurementHistory
            .filter({ $0.deletedAt == nil && $0.neckCircumference != nil })
            .sorted(by: { $0.date > $1.date })
            .first,
           let neckCircumference = latest.neckCircumference {
            selectedCentimeters = Int(neckCircumference)
            selectedInches = Int(neckCircumference / 2.54)
        }

        // Load recent entries
        _ = try? await interactor.readAllRemoteWeightEntries(userId: user.userId)
    }

    func saveMeasurement() async {
        guard let user = interactor.currentUser else { return }

        isLoading = true

        do {
            // Check if entry exists for this date
            let existingEntries = interactor.measurementHistory
                .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) && $0.deletedAt == nil }
            
            if let existingEntry = existingEntries.first {
                let updatedEntry = existingEntry.withUpdated(.neck(measurementCm))
                try await interactor.updateWeightEntry(entry: updatedEntry)
            } else {
                // Create new entry
                let entry = BodyMeasurementEntry(
                    authorId: user.userId,
                    weightKg: nil,
                    neckCircumference: measurementCm,
                    date: selectedDate
                )
                try await interactor.createWeightEntry(weightEntry: entry)
            }

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

    func onDismissPressed() {
        router.dismissScreen()
    }
}
