import SwiftUI

@Observable
@MainActor
class TutorialsPresenter {
    
    private let interactor: TutorialsInteractor
    private let router: TutorialsRouter
    
    init(interactor: TutorialsInteractor, router: TutorialsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onResetTutorialsPressed() {
        
    }

    func onViewAppear(delegate: TutorialsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: TutorialsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension TutorialsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: TutorialsDelegate)
        case onDisappear(delegate: TutorialsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "TutorialsView_Appear"
            case .onDisappear:              return "TutorialsView_Disappear"
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
