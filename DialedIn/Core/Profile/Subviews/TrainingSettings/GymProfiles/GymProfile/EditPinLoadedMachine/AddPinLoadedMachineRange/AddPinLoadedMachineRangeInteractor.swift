import SwiftUI

@MainActor
protocol AddPinLoadedMachineRangeInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddPinLoadedMachineRangeInteractor { }
