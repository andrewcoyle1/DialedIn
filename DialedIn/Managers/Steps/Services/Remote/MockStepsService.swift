//
//  MockRemoteStepsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import Foundation

struct MockStepsService: RemoteStepsService {
    
    let delay: Double
    let showError: Bool
    private var steps: [StepsModel]
    
    init(delay: Double = 0.0, showError: Bool = false, hasData: Bool = true) {
        self.delay = delay
        self.showError = showError
        self.steps = hasData ? StepsModel.mocks : []
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }

    func createStepsEntry(steps: StepsModel) async throws {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func readStepsEntry(userId: String, stepsId: String) async throws -> StepsModel {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return steps.first(where: { $0.id == stepsId })!
    }
    
    func readAllStepsEntriesForAuthor(userId: String) async throws -> [StepsModel] {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return steps
    }
    
    func updateStepsEntry(steps: StepsModel) async throws {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func deleteStepsEntry(userId: String, stepsId: String) async throws {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}
