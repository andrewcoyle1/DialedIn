//
//  LogRightAnkleMeasurementPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI

@Observable
@MainActor
class LogRightAnkleMeasurementPresenter {
    private let interactor: LogRightAnkleMeasurementInteractor
    private let router: LogRightAnkleMeasurementRouter

    var selectedDate = Date()
    var selectedCentimeters: Int = 22
    var selectedInches: Int = 9
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
        interactor: LogRightAnkleMeasurementInteractor,
        router: LogRightAnkleMeasurementRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func loadInitialData() async {
        guard let user = interactor.currentUser else { return }

        if let preference = user.submittedLengthUnitPreference {
            unit = preference == .centimeters ? .centimeters : .inches
        }

        if let latest = interactor.bodyMeasurements
            .filter({ $0.deletedAt == nil && $0.rightAnkleCircumference != nil })
            .sorted(by: { $0.date > $1.date })
            .first,
           let rightAnkleCircumference = latest.rightAnkleCircumference {
            selectedCentimeters = Int(rightAnkleCircumference)
            selectedInches = Int(rightAnkleCircumference / 2.54)
        }
    }

    func saveMeasurement() async {
        guard let user = interactor.currentUser else { return }

        isLoading = true

        do {
            let existingEntries = interactor.bodyMeasurements
                .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) && $0.deletedAt == nil }

            if let existingEntry = existingEntries.first {
                let updatedEntry = existingEntry.withUpdated(.rightAnkle(measurementCm))
                try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
            } else {
                let entry = BodyMeasurementEntry(
                    authorId: user.userId,
                    weightKg: nil,
                    rightAnkleCircumference: measurementCm,
                    date: selectedDate
                )
                try await interactor.saveBodyMeasurement(bodyMeasurement: entry)
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
