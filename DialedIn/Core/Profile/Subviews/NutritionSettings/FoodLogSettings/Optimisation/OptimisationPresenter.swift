import SwiftUI

@Observable
@MainActor
class OptimisationPresenter {

    private let interactor: OptimisationInteractor
    private let router: OptimisationRouter

    private var settings: FoodLogSettings

    var quickAddEnabled: Bool {
        get { settings.quickAddEnabled }
        set { settings.quickAddEnabled = newValue; save() }
    }

    init(interactor: OptimisationInteractor, router: OptimisationRouter) {
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

extension OptimisationPresenter {
    enum Event: LoggableEvent {
        case onAppear

        var eventName: String {
            switch self {
            case .onAppear: return "OptimisationView_Appear"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}
