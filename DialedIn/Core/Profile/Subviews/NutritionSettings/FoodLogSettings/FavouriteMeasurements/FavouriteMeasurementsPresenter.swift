import SwiftUI

@Observable
@MainActor
class FavouriteMeasurementsPresenter {

    private let interactor: FavouriteMeasurementsInteractor
    private let router: FavouriteMeasurementsRouter

    private var settings: FoodLogSettings

    let allMeasurements: [String] = ["g", "oz", "ml", "cup", "tbsp", "tsp", "serving", "kcal", "kJ"]

    var favouriteMeasurements: [String] {
        settings.favouriteMeasurements
    }

    func isSelected(_ measurement: String) -> Bool {
        favouriteMeasurements.contains(measurement)
    }

    func toggleMeasurement(_ measurement: String) {
        if isSelected(measurement) {
            settings.favouriteMeasurements.removeAll { $0 == measurement }
        } else {
            settings.favouriteMeasurements.append(measurement)
        }
        save()
    }

    init(interactor: FavouriteMeasurementsInteractor, router: FavouriteMeasurementsRouter) {
        self.interactor = interactor
        self.router = router
        self.settings = interactor.foodLogSettings
    }

    private func save() {
        Task { try? await interactor.saveFoodLogSettings(settings) }
    }

    /// Re-read rather than trusting the snapshot taken at init: `save()` writes the whole
    /// `FoodLogSettings` document, so a stale copy would revert whatever a sibling screen — or the
    /// favourite food and recipe ids written from the nutrition tab — saved in the meantime.
    func onViewAppear() {
        settings = interactor.foodLogSettings
        interactor.trackScreenEvent(event: Event.onAppear)
    }
}

extension FavouriteMeasurementsPresenter {
    enum Event: LoggableEvent {
        case onAppear

        var eventName: String {
            switch self {
            case .onAppear: return "FavouriteMeasurementsView_Appear"
            }
        }

        var parameters: [String: Any]? { nil }

        var type: LogType { .analytic }
    }
}
