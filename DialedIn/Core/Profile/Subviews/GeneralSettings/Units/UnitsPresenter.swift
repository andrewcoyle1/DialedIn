import SwiftUI

@Observable
@MainActor
class UnitsPresenter {
    
    private let interactor: UnitsInteractor
    private let router: UnitsRouter
    
    var weightUnit: WeightUnitPreference = .kilograms
    var heightUnit: HeightUnitPreference = .centimeters
    var clockUnit: ClockUnitPreference = .twelveHour
    var distanceUnit: LengthUnitPreference = .centimeters

    init(interactor: UnitsInteractor, router: UnitsRouter) {
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

extension UnitsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "UnitsView_Appear"
            case .onDisappear: return "UnitsView_Disappear"
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
