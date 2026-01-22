import SwiftUI

@MainActor
protocol EditWeightRangeInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditWeightRangeInteractor { }
