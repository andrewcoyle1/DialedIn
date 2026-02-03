import SwiftUI

@Observable
@MainActor
class WorkoutSettingsPresenter {
    
    private let interactor: WorkoutSettingsInteractor
    private let router: WorkoutSettingsRouter
    
    init(interactor: WorkoutSettingsInteractor, router: WorkoutSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: WorkoutSettingsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: WorkoutSettingsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension WorkoutSettingsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: WorkoutSettingsDelegate)
        case onDisappear(delegate: WorkoutSettingsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "WorkoutSettingsView_Appear"
            case .onDisappear:              return "WorkoutSettingsView_Disappear"
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
