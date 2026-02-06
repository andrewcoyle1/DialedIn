import SwiftUI

@MainActor
protocol InsightsAndAnalyticsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: InsightsAndAnalyticsInteractor { }
