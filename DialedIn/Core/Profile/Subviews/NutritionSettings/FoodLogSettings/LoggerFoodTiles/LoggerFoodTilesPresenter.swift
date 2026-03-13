import SwiftUI

@Observable
@MainActor
class LoggerFoodTilesPresenter {

    private let interactor: LoggerFoodTilesInteractor
    private let router: LoggerFoodTilesRouter

    private var settings: FoodLogSettings

    var showFoodImageInLogger: Bool {
        get { settings.showFoodImageInLogger }
        set { settings.showFoodImageInLogger = newValue; save() }
    }

    var showCaloriesInLogger: Bool {
        get { settings.showCaloriesInLogger }
        set { settings.showCaloriesInLogger = newValue; save() }
    }

    var showMacrosInLogger: Bool {
        get { settings.showMacrosInLogger }
        set { settings.showMacrosInLogger = newValue; save() }
    }

    var showPortionInLogger: Bool {
        get { settings.showPortionInLogger }
        set { settings.showPortionInLogger = newValue; save() }
    }

    init(interactor: LoggerFoodTilesInteractor, router: LoggerFoodTilesRouter) {
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

extension LoggerFoodTilesPresenter {
    enum Event: LoggableEvent {
        case onAppear

        var eventName: String {
            switch self {
            case .onAppear: return "LoggerFoodTilesView_Appear"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}
