//
//  LogRightForearmMeasurementPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI

@Observable
@MainActor
class LogRightForearmMeasurementPresenter {
    private let interactor: LogRightForearmMeasurementInteractor
    private let router: LogRightForearmMeasurementRouter

    var selectedDate = Date()
    var selectedCentimeters: Int = 30
    var selectedInches: Int = 12
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
        interactor: LogRightForearmMeasurementInteractor,
        router: LogRightForearmMeasurementRouter
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
            .filter({ $0.deletedAt == nil && $0.rightForearmCircumference != nil })
            .sorted(by: { $0.date > $1.date })
            .first,
           let rightForearmCircumference = latest.rightForearmCircumference {
            selectedCentimeters = Int(rightForearmCircumference)
            selectedInches = Int(rightForearmCircumference / 2.54)
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
                let updatedEntry = existingEntry.withUpdated(.rightForearm(measurementCm))
                try await interactor.updateWeightEntry(entry: updatedEntry)
            } else {
                let entry = BodyMeasurementEntry(
                    authorId: user.userId,
                    weightKg: nil,
                    rightForearmCircumference: measurementCm,
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
