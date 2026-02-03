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
}
