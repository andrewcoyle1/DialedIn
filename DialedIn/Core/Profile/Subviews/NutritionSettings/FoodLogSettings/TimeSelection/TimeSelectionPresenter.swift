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

    /// Re-read rather than trusting the snapshot taken at init: `save()` writes the whole
    /// `FoodLogSettings` document, so a stale copy would revert whatever a sibling screen — or the
    /// favourite food and recipe ids written from the nutrition tab — saved in the meantime.
    func onViewAppear() {
        settings = interactor.foodLogSettings
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
