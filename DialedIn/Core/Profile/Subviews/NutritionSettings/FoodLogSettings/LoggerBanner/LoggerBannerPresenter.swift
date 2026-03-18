import SwiftUI

@Observable
@MainActor
class LoggerBannerPresenter {

    private let interactor: LoggerBannerInteractor
    private let router: LoggerBannerRouter

    private var settings: FoodLogSettings

    var showCaloriesRing: Bool {
        get { settings.showCaloriesRing }
        set { settings.showCaloriesRing = newValue; save() }
    }

    var showProteinRing: Bool {
        get { settings.showProteinRing }
        set { settings.showProteinRing = newValue; save() }
    }

    var showFatRing: Bool {
        get { settings.showFatRing }
        set { settings.showFatRing = newValue; save() }
    }

    var showCarbsRing: Bool {
        get { settings.showCarbsRing }
        set { settings.showCarbsRing = newValue; save() }
    }

    init(interactor: LoggerBannerInteractor, router: LoggerBannerRouter) {
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

extension LoggerBannerPresenter {
    enum Event: LoggableEvent {
        case onAppear

        var eventName: String {
            switch self {
            case .onAppear: return "LoggerBannerView_Appear"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}
