import SwiftUI

@MainActor
protocol SiriInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: SiriInteractor { }
