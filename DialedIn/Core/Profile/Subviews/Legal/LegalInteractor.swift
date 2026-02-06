import SwiftUI

@MainActor
protocol LegalInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: LegalInteractor { }
