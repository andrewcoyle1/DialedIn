//
//  AddMealPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class AddMealPresenter {
    private let interactor: AddMealInteractor
    private let router: AddMealRouter
    
    var mealLog: MealLogModel {
        didSet {
            guard !mealLog.items.isEmpty else { return }
            saveDraftMeal()
        }
    }
    
    var showAllNutrients: Bool = false
    var nutritionScope: NutritionScope = .plate
    
    init(
        interactor: AddMealInteractor,
        router: AddMealRouter,
        delegate: AddMealDelegate
    ) {
        self.interactor = interactor
        self.router = router
        self.mealLog = delegate.mealLog
    }
    
    func onViewAppear() {
        interactor.trackEvent(event: Event.onAppear)
    }

    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    var currentUser: UserModel? {
        interactor.currentUser
    }
        
    func deleteItems(at offsets: IndexSet) {
        mealLog.items.remove(atOffsets: offsets)
    }
    
    func onEditMealItem(_ item: MealItemModel) {
        router.showMealItemAmountViewView(delegate: MealItemAmountViewDelegate(
            mode: .editItem(item),
            onConfirm: { [weak self] updatedItem in
                guard let self,
                      let idx = self.mealLog.items.firstIndex(where: { $0.itemId == updatedItem.itemId })
                else { return }
                self.mealLog.items[idx] = updatedItem
            }
        ))
    }

    func onShowPickerPressed() {
        let delegate = NutritionLibraryPickerDelegate(
            items: Binding(get: {
                self.mealLog.items
            }, set: { newValues in
                self.mealLog.items = newValues
            }),
            onPick: { newItem in
                self.mealLog.items.append(newItem)
        })
        router.showNutritionLibraryPickerView(delegate: delegate)
    }
    
    // MARK: - Persistence
    
    func saveDraftMeal() {
        do {
            try interactor.updateDraftMeal(mealLog)
        } catch {
            router.showSimpleAlert(title: "Unable to Save Progress", subtitle: "We were unable to save your workout. Please try again.")
        }
    }

    func saveMeal() {
        Task {
            interactor.trackEvent(event: Event.saveMealStart)
            do {
                try await interactor.saveMeal(mealLog)
                try interactor.deleteDraftMeal()
                interactor.trackEvent(event: Event.saveMealSuccess)
                self.dismissScreen()
            } catch {
                interactor.trackEvent(event: Event.saveMealFail(error: error))
            }
        }
    }

    func dismissScreen() {
        if self.mealLog.items.isEmpty {
            try? self.interactor.deleteDraftMeal()
        }
        router.dismissScreen()
    }

    // MARK: - Nutrition Display

    var plateCalories: Double { mealLog.totalCalories }
    var plateProtein: Double { mealLog.totalProteinGrams }
    var plateCarbs: Double { mealLog.totalCarbGrams }
    var plateFat: Double { mealLog.totalFatGrams }

    private var committedDailyTotals: DailyMacroTarget? {
        try? interactor.getDailyTotals(dayKey: mealLog.dayKey)
    }

    var displayCalories: Double {
        nutritionScope == .plate ? plateCalories : (committedDailyTotals?.calories ?? 0) + plateCalories
    }
    var displayProtein: Double {
        nutritionScope == .plate ? plateProtein : (committedDailyTotals?.proteinGrams ?? 0) + plateProtein
    }
    var displayCarbs: Double {
        nutritionScope == .plate ? plateCarbs : (committedDailyTotals?.carbGrams ?? 0) + plateCarbs
    }
    var displayFat: Double {
        nutritionScope == .plate ? plateFat : (committedDailyTotals?.fatGrams ?? 0) + plateFat
    }

    var dailyTarget: DailyMacroTarget? {
        guard let plan = interactor.currentDietPlan else { return nil }
        let weekday = Calendar.current.component(.weekday, from: mealLog.date)
        let index = (weekday + 5) % 7 // Sun=1..Sat=7 → Mon=0..Sun=6
        guard plan.days.indices.contains(index) else { return nil }
        return plan.days[index]
    }

    var targetCalories: Double { dailyTarget?.calories ?? 2000 }
    var targetProtein: Double { dailyTarget?.proteinGrams ?? 150 }
    var targetCarbs: Double { dailyTarget?.carbGrams ?? 200 }
    var targetFat: Double { dailyTarget?.fatGrams ?? 65 }

    var calorieLabel: String { "\(Int(displayCalories))/\(Int(targetCalories))" }
    var scopeLabel: String { nutritionScope == .plate ? "in plate" : "today" }
}

extension AddMealPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case saveMealStart
        case saveMealSuccess
        case saveMealFail(error: Error)
        
        var eventName: String {
            switch self {
            case .onAppear:         return "AddMealView_Appear"
            case .onDisappear:      return "AddMealView_Disappear"
            case .saveMealStart:    return "AddMealView_SaveMeal_Start"
            case .saveMealSuccess:  return "AddMealView_SaveMeal_Success"
            case .saveMealFail:     return "AddMealView_SaveMeal_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .saveMealFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .saveMealFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

enum NutritionScope: String, DataSyncModelProtocol, CaseIterable {
    var id: String { self.rawValue }
    case plate
    case day
}

enum AddMealError: LocalizedError { case noCurrentUser }
