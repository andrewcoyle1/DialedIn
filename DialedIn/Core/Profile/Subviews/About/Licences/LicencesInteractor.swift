import SwiftUI

@MainActor
protocol LicencesInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: LicencesInteractor { }
