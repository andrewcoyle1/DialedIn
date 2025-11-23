//
//  MealLogViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
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

@MainActor
protocol MealLogRouter {
    func showAddMealView(delegate: AddMealSheetDelegate)
    func showMealDetailView(delegate: MealDetailViewDelegate)
    func showAlert(error: Error)
}

extension CoreRouter: MealLogRouter { }

@Observable
@MainActor
class MealLogViewModel {
    private let interactor: MealLogInteractor
    private let router: MealLogRouter

    var selectedDate: Date = Date()
    private(set) var meals: [MealLogModel] = []
    private(set) var dailyTotals: DailyMacroTarget?
    private(set) var dailyTarget: DailyMacroTarget?
    private(set) var isLoading: Bool = false
    var selectedMealType: MealType = .breakfast

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var dayKey: String {
        selectedDate.dayKey
    }
    
    init(
        interactor: MealLogInteractor,
        router: MealLogRouter
    ) {
        self.interactor = interactor
        self.router = router
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
            router.showAlert(error: error)
        }
    }
    
    func saveMeal(_ meal: MealLogModel) async {
        do {
            try await interactor.addMeal(meal)
            await loadMeals()

        } catch {
            router.showAlert(error: error)
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
            router.showAlert(error: error)
        }
    }

    func navToMealDetail(meal: MealLogModel) {
        router.showMealDetailView(delegate: MealDetailViewDelegate(meal: meal))
    }

    func onAddMealPressed(mealType: MealType) {
        let delegate = AddMealSheetDelegate(
            selectedDate: selectedDate,
            mealType: mealType,
            onSave: { meal in
                Task { [weak self] in
                    await self?.saveMeal(meal)
                }
            }
        )
        router.showAddMealView(delegate: delegate)
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "MealLogView_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
