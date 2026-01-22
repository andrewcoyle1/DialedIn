import SwiftUI

@MainActor
protocol EditBandInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditBandInteractor { }
