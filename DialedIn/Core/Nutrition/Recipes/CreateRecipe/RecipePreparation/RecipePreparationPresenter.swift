import SwiftUI

@Observable
@MainActor
class RecipePreparationPresenter {
    
    private let interactor: RecipePreparationInteractor
    private let router: RecipePreparationRouter
    
    init(interactor: RecipePreparationInteractor, router: RecipePreparationRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: RecipePreparationDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: RecipePreparationDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension RecipePreparationPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: RecipePreparationDelegate)
        case onDisappear(delegate: RecipePreparationDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "RecipePreparationView_Appear"
            case .onDisappear:              return "RecipePreparationView_Disappear"
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
