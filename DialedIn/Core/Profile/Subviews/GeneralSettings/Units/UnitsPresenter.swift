import SwiftUI

@Observable
@MainActor
class UnitsPresenter {
    
    private let interactor: UnitsInteractor
    private let router: UnitsRouter
    
    /// Mirrors of the stored preferences. They are written back through the interactor on every
    /// change, so the screen needs no Save button — matching the other settings screens.
    private var storedWeight: WeightUnitPreference
    private var storedLength: LengthUnitPreference
    private var storedDistance: DistanceUnitPreference

    var weightUnit: WeightUnitPreference {
        get { storedWeight }
        set { storedWeight = newValue; save() }
    }

    /// Covers height and every body measurement, which is what `LengthUnitPreference` governs
    /// everywhere else in the app.
    var heightUnit: LengthUnitPreference {
        get { storedLength }
        set { storedLength = newValue; save() }
    }

    var distanceUnit: DistanceUnitPreference {
        get { storedDistance }
        set { storedDistance = newValue; save() }
    }

    init(interactor: UnitsInteractor, router: UnitsRouter) {
        self.interactor = interactor
        self.router = router

        let user = interactor.currentUser
        let length = user?.submittedLengthUnitPreference ?? .centimeters
        // Distance gained its own preference after length, so fall back to what length implies
        // rather than showing metric to someone who onboarded in imperial.
        let distance = user?.submittedDistanceUnitPreference
            ?? (length == .centimeters ? .kilometers : .miles)

        self.storedWeight = user?.submittedWeightUnitPreference ?? .kilograms
        self.storedLength = length
        self.storedDistance = distance
    }

    private func save() {
        Task {
            try? await interactor.updateUnitPreferences(
                length: storedLength,
                weight: storedWeight,
                distance: storedDistance
            )
        }
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
