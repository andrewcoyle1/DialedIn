import SwiftUI

@Observable
@MainActor
class ShortcutsPresenter {
    
    private let interactor: ShortcutsInteractor
    private let router: ShortcutsRouter
    
    init(interactor: ShortcutsInteractor, router: ShortcutsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
}

extension ShortcutsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "ShortcutsView_Appear"
            case .onDisappear: return "ShortcutsView_Disappear"
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
