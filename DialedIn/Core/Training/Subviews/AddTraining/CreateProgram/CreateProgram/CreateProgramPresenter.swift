import SwiftUI

@Observable
@MainActor
class CreateProgramPresenter {
    
    private let interactor: CreateProgramInteractor
    private let router: CreateProgramRouter
    
    init(interactor: CreateProgramInteractor, router: CreateProgramRouter) {
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
    
    func onNextPressed() {
        router.showNameProgramView(delegate: NameProgramDelegate())
    }
    
}

extension CreateProgramPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "CreateProgramView_Appear"
            case .onDisappear: return "CreateProgramView_Disappear"
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
