import SwiftUI

@MainActor
protocol AddBandInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddBandInteractor { }
