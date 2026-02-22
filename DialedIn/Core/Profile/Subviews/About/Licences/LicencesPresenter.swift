import SwiftUI

@Observable
@MainActor
class LicencesPresenter {
    
    private let interactor: LicencesInteractor
    private let router: LicencesRouter
    
    init(interactor: LicencesInteractor, router: LicencesRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}

extension LicencesPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear

        var eventName: String {
            switch self {
            case .onAppear:             return "AppView_Appear"
            case .onDisappear:          return "AppView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
