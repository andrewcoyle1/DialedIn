import SwiftUI

@Observable
@MainActor
class NutritionOverviewPresenter {

    private let interactor: NutritionOverviewInteractor
    private let router: NutritionOverviewRouter

    var showsContributors: Bool = false

    private(set) var totals: DailyMacroTarget = DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0)
    private(set) var target: DailyMacroTarget?
    private(set) var breakdown: DailyNutritionBreakdown = .empty

    init(interactor: NutritionOverviewInteractor, router: NutritionOverviewRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: NutritionOverviewDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        loadData(delegate: delegate)
    }

    func onViewDisappear(delegate: NutritionOverviewDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    private func loadData(delegate: NutritionOverviewDelegate) {
        let dayKey = delegate.dayKey
        totals = (try? interactor.getDailyTotals(dayKey: dayKey)) ?? totals
        breakdown = (try? interactor.getDailyNutritionBreakdown(dayKey: dayKey)) ?? .empty
        guard let userId = interactor.userId else { return }
        let date = Date(dayKey: dayKey) ?? Date()
        Task {
            target = try? await interactor.getDailyTarget(for: date, userId: userId)
        }
    }

    // MARK: Progress helpers (0–1)

    var caloriesProgress: Double {
        guard let targetCal = target?.calories, targetCal > 0 else { return 0 }
        return min(totals.calories / targetCal, 1)
    }

    var proteinProgress: Double {
        guard let proteinTarget = target?.proteinGrams, proteinTarget > 0 else { return 0 }
        return min(totals.proteinGrams / proteinTarget, 1)
    }

    var carbsProgress: Double {
        guard let carbTarget = target?.carbGrams, carbTarget > 0 else { return 0 }
        return min(totals.carbGrams / carbTarget, 1)
    }

    var fatProgress: Double {
        guard let fatTarget = target?.fatGrams, fatTarget > 0 else { return 0 }
        return min(totals.fatGrams / fatTarget, 1)
    }
}

extension NutritionOverviewPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: NutritionOverviewDelegate)
        case onDisappear(delegate: NutritionOverviewDelegate)

        var eventName: String {
            switch self {
            case .onAppear:    return "NutritionOverviewView_Appear"
            case .onDisappear: return "NutritionOverviewView_Disappear"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(let delegate), .onDisappear(let delegate):
                return delegate.eventParameters
            }
        }

        var type: LogType {
            switch self {
            default: return .analytic
            }
        }
    }
}
