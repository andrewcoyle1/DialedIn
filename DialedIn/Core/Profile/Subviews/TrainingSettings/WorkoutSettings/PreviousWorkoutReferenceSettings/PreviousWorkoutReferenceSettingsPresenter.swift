import SwiftUI

@Observable
@MainActor
class PrevWORefSettingsPresenter {
    
    private let interactor: PrevWORefSettingsInteractor
    private let router: PreviousWorkoutReferenceSettingsRouter
    
    init(interactor: PrevWORefSettingsInteractor, router: PreviousWorkoutReferenceSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: PrevWORefSettingsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: PrevWORefSettingsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension PrevWORefSettingsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: PrevWORefSettingsDelegate)
        case onDisappear(delegate: PrevWORefSettingsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "PreviousWorkoutReferenceSettingsView_Appear"
            case .onDisappear:              return "PreviousWorkoutReferenceSettingsView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
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
