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

    /// Re-read rather than trusting the snapshot taken at init: `save()` writes the whole
    /// `FoodLogSettings` document, so a stale copy would revert whatever a sibling screen — or the
    /// favourite food and recipe ids written from the nutrition tab — saved in the meantime.
    func onViewAppear() {
        settings = interactor.foodLogSettings
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
