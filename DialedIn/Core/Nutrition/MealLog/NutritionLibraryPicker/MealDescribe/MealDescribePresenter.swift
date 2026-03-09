import SwiftUI

@Observable
@MainActor
class MealDescribePresenter {
    
    private let interactor: MealDescribeInteractor
    private let router: MealDescribeRouter
    
    var descriptionText: String = ""
    
    init(interactor: MealDescribeInteractor, router: MealDescribeRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: MealDescribeDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: MealDescribeDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension MealDescribePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: MealDescribeDelegate)
        case onDisappear(delegate: MealDescribeDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "MealDescribeView_Appear"
            case .onDisappear:              return "MealDescribeView_Disappear"
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
