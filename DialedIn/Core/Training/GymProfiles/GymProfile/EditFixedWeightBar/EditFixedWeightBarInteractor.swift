import SwiftUI

@MainActor
protocol EditFixedWeightBarInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditFixedWeightBarInteractor { }
