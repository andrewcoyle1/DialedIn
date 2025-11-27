//
//  MealLogPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class MealLogPresenter {
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
        router.showMealDetailView(delegate: MealDetailDelegate(meal: meal))
    }

    func onAddMealPressed(mealType: MealType) {
        let delegate = AddMealDelegate(
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
