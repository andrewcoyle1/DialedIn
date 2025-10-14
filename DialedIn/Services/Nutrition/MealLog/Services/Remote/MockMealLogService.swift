//
//  MockMealLogService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import Foundation

struct MockMealLogService: RemoteMealLogService {
    private var store: [String: [MealLogModel]]
    private let delay: Double
    private let showError: Bool

    init(mealsByDay: [String: [MealLogModel]] = [:], delay: Double = 0.0, showError: Bool = false) {
        self.store = mealsByDay
        self.delay = delay
        self.showError = showError
    }

    func createMeal(_ meal: MealLogModel) async throws {
        try await simulateDelayAndMaybeError()
    }

    func updateMeal(_ meal: MealLogModel) async throws {
        try await simulateDelayAndMaybeError()
    }

    func deleteMeal(id: String, dayKey: String, authorId: String) async throws {
        try await simulateDelayAndMaybeError()
    }

    func getMeals(dayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        try await simulateDelayAndMaybeError()
        return store[dayKey] ?? []
    }

    func getMeals(startDayKey: String, endDayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        try await simulateDelayAndMaybeError()
        let keys = store.keys.sorted().filter { $0 >= startDayKey && $0 <= endDayKey }
        return keys.flatMap { store[$0] ?? [] }
    }

    private func simulateDelayAndMaybeError() async throws {
        if delay > 0 { try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) }
        if showError { throw NSError(domain: "MockMealLogService", code: -1) }
    }
}
