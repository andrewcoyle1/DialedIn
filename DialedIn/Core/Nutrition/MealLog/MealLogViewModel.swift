//
//  MealLogViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol MealLogInteractor {
    var currentUser: UserModel? { get }
    func getMeals(for dayKey: String) throws -> [MealLogModel]
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget?
    func addMeal(_ meal: MealLogModel) async throws
    func deleteMealAndSync(id: String, dayKey: String, authorId: String) async throws
}

extension CoreInteractor: MealLogInteractor { }

@Observable
@MainActor
class MealLogViewModel {
    private let interactor: MealLogInteractor
    
    var selectedDate: Date = Date()
    private(set) var meals: [MealLogModel] = []
    private(set) var dailyTotals: DailyMacroTarget?
    private(set) var dailyTarget: DailyMacroTarget?
    private(set) var isLoading: Bool = false
    var selectedMealType: MealType = .breakfast
    
    var showAlert: AnyAppAlert?
    var showAddMealSheet: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var dayKey: String {
        selectedDate.dayKey
    }
    
    init(
        interactor: MealLogInteractor
    ) {
        self.interactor = interactor
    }
    
    func mealTypeIcon(_ mealType: MealType) -> String {
        switch mealType {
        case .breakfast:
            return "sunrise.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "moon.stars.fill"
        case .snack:
            return "fork.knife"
        }
    }
    
    func loadMeals() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            meals = try interactor.getMeals(for: dayKey).sorted(by: { $0.date < $1.date })
            dailyTotals = try interactor.getDailyTotals(dayKey: dayKey)
            
            // Load target for the day (if diet plan exists)
            if let user = interactor.currentUser {
                dailyTarget = try await interactor.getDailyTarget(for: selectedDate, userId: user.userId)
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    func saveMeal(_ meal: MealLogModel) async {
        do {
            try await interactor.addMeal(meal)
            await loadMeals()
            showAddMealSheet = false
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    func deleteMeal(_ meal: MealLogModel) async {
        do {
            try await interactor.deleteMealAndSync(
                id: meal.mealId,
                dayKey: meal.dayKey,
                authorId: meal.authorId
            )
            await loadMeals()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}
