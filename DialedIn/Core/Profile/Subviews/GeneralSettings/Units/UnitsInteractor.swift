import SwiftUI

@MainActor
protocol UnitsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: UnitsInteractor { }
