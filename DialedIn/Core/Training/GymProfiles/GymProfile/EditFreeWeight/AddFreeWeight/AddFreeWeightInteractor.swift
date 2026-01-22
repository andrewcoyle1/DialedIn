import SwiftUI

@MainActor
protocol AddFreeWeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddFreeWeightInteractor { }
