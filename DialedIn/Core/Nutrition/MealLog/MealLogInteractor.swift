//
//  MealLogInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol MealLogInteractor {
    var currentUser: UserModel? { get }
    func getMeals(for dayKey: String) throws -> [MealLogModel]
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget?
    func addMeal(_ meal: MealLogModel) async throws
    func deleteMealAndSync(id: String, dayKey: String, authorId: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: MealLogInteractor { }
