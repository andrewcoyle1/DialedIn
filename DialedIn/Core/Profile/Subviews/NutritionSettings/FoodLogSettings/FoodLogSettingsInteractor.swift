import SwiftUI

@MainActor
protocol FoodLogSettingsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: FoodLogSettingsInteractor { }
