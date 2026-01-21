import SwiftUI

@MainActor
protocol EditFreeWeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditFreeWeightInteractor { }
