import SwiftUI

@Observable
@MainActor
class TimeSelectionPresenter {

    private let interactor: TimeSelectionInteractor
    private let router: TimeSelectionRouter

    private var settings: FoodLogSettings

    var autoSetCurrentTime: Bool {
        get { settings.autoSetCurrentTime }
        set { settings.autoSetCurrentTime = newValue; save() }
    }

    init(interactor: TimeSelectionInteractor, router: TimeSelectionRouter) {
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

extension TimeSelectionPresenter {
    enum Event: LoggableEvent {
        case onAppear

        var eventName: String {
            switch self {
            case .onAppear: return "TimeSelectionView_Appear"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}
