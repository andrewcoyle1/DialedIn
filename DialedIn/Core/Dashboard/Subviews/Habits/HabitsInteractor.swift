import SwiftUI

@MainActor
protocol HabitsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: HabitsInteractor { }
