import SwiftUI

@Observable
@MainActor
class TimelineFoodTilesPresenter {

    private let interactor: TimelineFoodTilesInteractor
    private let router: TimelineFoodTilesRouter

    private var settings: FoodLogSettings

    var showFoodImageInTimeline: Bool {
        get { settings.showFoodImageInTimeline }
        set { settings.showFoodImageInTimeline = newValue; save() }
    }

    var showCaloriesInTimeline: Bool {
        get { settings.showCaloriesInTimeline }
        set { settings.showCaloriesInTimeline = newValue; save() }
    }

    var showMacrosInTimeline: Bool {
        get { settings.showMacrosInTimeline }
        set { settings.showMacrosInTimeline = newValue; save() }
    }

    init(interactor: TimelineFoodTilesInteractor, router: TimelineFoodTilesRouter) {
        self.interactor = interactor
        self.router = router
        self.settings = interactor.foodLogSettings
    }

    private func save() {
        Task { try? await interactor.saveFoodLogSettings(settings) }
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
}

extension TimelineFoodTilesPresenter {
    enum Event: LoggableEvent {
        case onAppear

        var eventName: String {
            switch self {
            case .onAppear: return "TimelineFoodTilesView_Appear"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}
