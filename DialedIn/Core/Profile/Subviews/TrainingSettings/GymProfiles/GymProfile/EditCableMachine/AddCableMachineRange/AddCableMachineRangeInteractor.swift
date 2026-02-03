import SwiftUI

@MainActor
protocol AddCableMachineRangeInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddCableMachineRangeInteractor { }
