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
    
    var draftMeal: MealLogModel? {
        interactor.draftMeal
    }

    var mealsForSelectedDate: [MealLogModel] {
        (try? interactor.getMeals(for: selectedDate.dayKey)) ?? []
    }

    func meals(inHour hour: Date) -> [MealLogModel] {
        let cal = Calendar.current
        return mealsForSelectedDate.filter { cal.isDate($0.date, equalTo: hour, toGranularity: .hour) }
    }
    
    var dailyTotals: DailyMacroTarget? {
        try? interactor.getDailyTotals(dayKey: dayKey)
    }

    var dailyTarget: DailyMacroTarget? {
        guard let plan = interactor.currentDietPlan else { return nil }
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        let dayIndex = (weekday + 5) % 7
        guard dayIndex < plan.days.count else { return nil }
        return plan.days[dayIndex]
    }

    var workingHours: [Date] {
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: selectedDate)!
        let end = calendar.date(bySettingHour: endHour, minute: 0, second: 0, of: selectedDate)!
        
        var dates: [Date] = []
        var current = start
        
        // Step through hour by hour until reaching the end
        while current <= end {
            dates.append(current)
            current = calendar.date(byAdding: .hour, value: 1, to: current)!
        }
        return dates
    }
    
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

    var showCalendarWeekBanner: Bool { interactor.foodLogSettings.showCalendarWeekBanner }
    var showsFoodTimestamps: Bool { interactor.foodLogSettings.showsFoodTimestamps }
    var startHour: Int { interactor.foodLogSettings.startHour }
    var endHour: Int { interactor.foodLogSettings.endHour }
    var timestampSide: TimestampSide { interactor.foodLogSettings.timestampSide }
    var showCaloriesRing: Bool { interactor.foodLogSettings.showCaloriesRing }
    var showProteinRing: Bool { interactor.foodLogSettings.showProteinRing }
    var showFatRing: Bool { interactor.foodLogSettings.showFatRing }
    var showCarbsRing: Bool { interactor.foodLogSettings.showCarbsRing }
    var showFoodImageInTimeline: Bool { interactor.foodLogSettings.showFoodImageInTimeline }
    var showCaloriesInTimeline: Bool { interactor.foodLogSettings.showCaloriesInTimeline }
    var showMacrosInTimeline: Bool { interactor.foodLogSettings.showMacrosInTimeline }

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
        scheduleMealRemindersIfNeeded()
    }

    func onViewDisappear(delegate: NutritionDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    private func scheduleMealRemindersIfNeeded() {
        let key = "hasMealRemindersScheduled"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        Task {
            do {
                try await interactor.scheduleMealReminderNotifications()
                UserDefaults.standard.set(true, forKey: key)
            } catch {
                // Silent — non-critical
            }
        }
    }
    
    func onProfilePressed() {
        router.showProfileView()
    }

    #if DEV || MOCK
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    #endif

//    func saveMeal(_ meal: MealLogModel) async {
//        do {
//            try await interactor.addMeal(meal)
//        } catch {
//            router.showAlert(error: error)
//        }
//    }
    
    func deleteMealItem(_ item: MealItemModel, from meal: MealLogModel) {
        var updatedMeal = meal
        updatedMeal.items.removeAll { $0.itemId == item.itemId }
        Task {
            interactor.trackEvent(event: Event.saveMealStart)
            do {
                if updatedMeal.items.isEmpty {
                    try await interactor.deleteMealAndSync(
                        id: meal.mealId,
                        dayKey: meal.dayKey,
                        authorId: meal.authorId
                    )
                } else {
                    try await interactor.addMeal(updatedMeal)
                }
                interactor.trackEvent(event: Event.saveMealSuccess)
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.saveMealFail(error: error))
            }
        }
    }

    func deleteMeal(_ meal: MealLogModel) {
        Task {
            interactor.trackEvent(event: Event.saveMealStart)
            do {
                try await interactor.deleteMealAndSync(
                    id: meal.mealId,
                    dayKey: meal.dayKey,
                    authorId: meal.authorId
                )
                interactor.trackEvent(event: Event.saveMealSuccess)
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.saveMealFail(error: error))
            }
        }
    }

    func onEditMealItem(_ item: MealItemModel) {
        router.showMealItemAmountViewView(
            delegate: MealItemAmountViewDelegate(
                mode: .editItem(item),
                onConfirm: { _ in
                    
                }
            )
        )
    }
    
    func onTimelineActionsPressed() {
        router.showTimelineActionsView(delegate: TimelineActionsDelegate())
    }
    
    func onCustomiseFoodLogPressed() {
        router.showFoodLogSettingsView(delegate: FoodLogSettingsDelegate())
    }
    
    func onNutritionOverviewPressed() {
        router.showNutritionOverviewView(delegate: NutritionOverviewDelegate(dayKey: dayKey))
    }

    func getMealCountForDate(date: Date) -> Int {
        (try? interactor.getMeals(for: date.dayKey).count) ?? 0
    }
}

extension NutritionPresenter {
    enum Event: LoggableEvent {
        case onAppear(delegate: NutritionDelegate)
        case onDisappear(delegate: NutritionDelegate)
        case saveMealStart
        case saveMealSuccess
        case saveMealFail(error: Error)
        
        var eventName: String {
            switch self {
            case .onAppear:         return "NutritionView_Appear"
            case .onDisappear:      return "NutritionView_Disappear"
            case .saveMealStart:    return "NutritionView_SaveMeal_Start"
            case .saveMealSuccess:  return "NutritionView_SaveMeal_Success"
            case .saveMealFail:     return "NutritionView_SaveMeal_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
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
