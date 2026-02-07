//
//  LogChestMeasurementPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI

@Observable
@MainActor
class LogChestMeasurementPresenter {
    private let interactor: LogChestMeasurementInteractor
    private let router: LogChestMeasurementRouter

    var selectedDate = Date()
    var selectedCentimeters: Int = 105
    var selectedInches: Int = 41
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
        interactor: LogChestMeasurementInteractor,
        router: LogChestMeasurementRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func loadInitialData() async {
        guard let user = interactor.currentUser else { return }

        if let preference = user.lengthUnitPreference {
            unit = preference == .centimeters ? .centimeters : .inches
        }

        if let latest = interactor.measurementHistory
            .filter({ $0.deletedAt == nil && $0.chestCircumference != nil })
            .sorted(by: { $0.date > $1.date })
            .first,
           let chestCircumference = latest.chestCircumference {
            selectedCentimeters = Int(chestCircumference)
            selectedInches = Int(chestCircumference / 2.54)
        }

        _ = try? await interactor.readAllRemoteWeightEntries(userId: user.userId)
    }

    func saveMeasurement() async {
        guard let user = interactor.currentUser else { return }

        isLoading = true

        do {
            let existingEntries = interactor.measurementHistory
                .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) && $0.deletedAt == nil }
            
            if let existingEntry = existingEntries.first {
                let updatedEntry = existingEntry.withUpdated(.chest(measurementCm))
                try await interactor.updateWeightEntry(entry: updatedEntry)
            } else {
                let entry = BodyMeasurementEntry(
                    authorId: user.userId,
                    weightKg: nil,
                    chestCircumference: measurementCm,
                    date: selectedDate
                )
                try await interactor.createWeightEntry(weightEntry: entry)
            }

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
