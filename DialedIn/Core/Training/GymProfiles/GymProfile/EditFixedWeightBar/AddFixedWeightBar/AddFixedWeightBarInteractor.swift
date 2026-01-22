import SwiftUI

@MainActor
protocol AddFixedWeightBarInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddFixedWeightBarInteractor { }
