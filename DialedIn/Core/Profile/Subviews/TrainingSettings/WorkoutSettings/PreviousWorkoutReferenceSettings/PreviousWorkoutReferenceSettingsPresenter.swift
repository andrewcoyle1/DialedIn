import SwiftUI

@Observable
@MainActor
class PreviousWorkoutReferenceSettingsPresenter {
    
    private let interactor: PreviousWorkoutReferenceSettingsInteractor
    private let router: PreviousWorkoutReferenceSettingsRouter
    
    init(interactor: PreviousWorkoutReferenceSettingsInteractor, router: PreviousWorkoutReferenceSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: PreviousWorkoutReferenceSettingsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: PreviousWorkoutReferenceSettingsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension PreviousWorkoutReferenceSettingsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: PreviousWorkoutReferenceSettingsDelegate)
        case onDisappear(delegate: PreviousWorkoutReferenceSettingsDelegate)

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
