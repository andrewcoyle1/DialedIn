//
//  AddMealInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol AddMealInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var draftMeal: MealLogModel? { get }
    var currentDietPlan: DietPlan? { get }
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func updateDraftMeal(_ draftMeal: MealLogModel) throws
    func deleteDraftMeal() throws
    func saveMeal(_ meal: MealLogModel) async throws
}

extension CoreInteractor: AddMealInteractor { }
