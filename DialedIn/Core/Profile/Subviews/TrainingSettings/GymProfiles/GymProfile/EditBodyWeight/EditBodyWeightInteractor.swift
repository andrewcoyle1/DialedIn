import SwiftUI

@MainActor
protocol EditBodyWeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditBodyWeightInteractor { }
