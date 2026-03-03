//
//  NutritionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class NutritionPresenter {
    private let interactor: NutritionInteractor
    private let router: NutritionRouter
   
    var selectedDate: Date = Date()
    var meals: [MealLogModel] {
        interactor.userMeals
    }
    
    private(set) var dailyTotals: DailyMacroTarget?
    private(set) var dailyTarget: DailyMacroTarget?
    private(set) var isLoading: Bool = false

    var caloriePercentage: Double {
        guard let target = dailyTarget?.calories, target > 0 else { return 0 }
        return (dailyTotals?.calories ?? 0) / target
    }
    
    var proteinPercentage: Double {
        guard let target = dailyTarget?.proteinGrams, target > 0 else { return 0 }
        return (dailyTotals?.proteinGrams ?? 0) / target
    }

    var fatPercentage: Double {
        guard let target = dailyTarget?.fatGrams, target > 0 else { return 0 }
        return (dailyTotals?.fatGrams ?? 0) / target
    }

    var carbsPercentage: Double {
        guard let target = dailyTarget?.carbGrams, target > 0 else { return 0 }
        return (dailyTotals?.carbGrams ?? 0) / target
    }

    var currentUser: UserModel? {
        interactor.currentUser
    }

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    var dayKey: String {
        selectedDate.dayKey
    }
    
    init(
        interactor: NutritionInteractor,
        router: NutritionRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: NutritionDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: NutritionDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onProfilePressed() {
        router.showProfileView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    func onRecipeLibraryPressed() {
        router.showRecipesView()
    }
    
    func onIngredientLibraryPressed() {
        router.showIngredientsView()
    }
            
    func saveMeal(_ meal: MealLogModel) async {
        do {
            try await interactor.addMeal(meal)
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
        } catch {
            router.showAlert(error: error)
        }
    }

    func navToMealDetail(meal: MealLogModel) {
        router.showMealDetailView(delegate: MealDetailDelegate(meal: meal))
    }
    
    func onTimelineActionsPressed() {
        router.showTimelineActionsView(delegate: TimelineActionsDelegate())
    }

    func onAddMealPressed() {
        let delegate = AddMealDelegate(
            selectedDate: selectedDate,
            onSave: { meal in
                Task { [weak self] in
                    await self?.saveMeal(meal)
                }
            }
        )
        router.showAddMealView(delegate: delegate)
    }

    func getMealCountForDate(date: Date) -> Int {
        (try? interactor.getMeals(for: date.dayKey).count) ?? 0
    }
}

extension NutritionPresenter {
    enum Event: LoggableEvent {
        case onAppear(delegate: NutritionDelegate)
        case onDisappear(delegate: NutritionDelegate)
        
        var eventName: String {
            switch self {
            case .onAppear: return "NutritionView_Appear"
            case .onDisappear: return "NutritionView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
