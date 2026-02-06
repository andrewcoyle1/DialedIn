import SwiftUI

@MainActor
protocol NutritionAnalyticsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: NutritionAnalyticsInteractor { }
