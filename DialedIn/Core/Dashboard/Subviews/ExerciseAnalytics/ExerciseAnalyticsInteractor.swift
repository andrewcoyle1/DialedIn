import SwiftUI

@MainActor
protocol ExerciseAnalyticsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ExerciseAnalyticsInteractor { }
