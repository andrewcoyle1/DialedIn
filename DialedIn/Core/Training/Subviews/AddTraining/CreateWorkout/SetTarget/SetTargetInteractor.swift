import SwiftUI

@MainActor
protocol SetTargetInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: SetTargetInteractor { }
