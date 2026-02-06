import SwiftUI

@MainActor
protocol AddBodyWeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddBodyWeightInteractor { }
