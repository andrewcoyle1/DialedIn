//
//  MockLocalStepsModelService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import Foundation

final class MockStepsPersistence: LocalStepsPersistence {
    
    let delay: Double
    let showError: Bool

    private var stepsArray: [StepsModel] = []

    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }

    init(delay: Double, showError: Bool, hasData: Bool = true) {
        self.delay = delay
        self.showError = showError
        self.stepsArray = hasData ? [StepsModel.mock] : []
    }

    // MARK: CREATE
    func createStepsEntry(steps: StepsModel) throws {
        try tryShowError()
        // Upsert by id to avoid duplicates when refreshing
        stepsArray.removeAll { $0.id == steps.id }
        stepsArray.append(steps)
    }

    // MARK: READ
    func readStepsEntry(id: String) throws -> StepsModel {
        try tryShowError()
        return StepsModel.mock
    }

    func readAllLocalStepsEntries() throws -> [StepsModel] {
        try tryShowError()
        return StepsModel.mocks
    }

    // MARK: UPDATE
    func updateStepsEntry(steps: StepsModel) throws {
        try tryShowError()
        stepsArray.removeAll { $0.id == steps.id }
        stepsArray.append(steps)
    }

    // MARK: DELETE
    func deleteStepsEntry(id: String) throws {
        try tryShowError()
        stepsArray.removeAll { $0.id == id }
    }

    func deleteAllLocalStepsEntries() throws {
        try tryShowError()
        stepsArray.removeAll()
    }
}
