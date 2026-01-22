import SwiftUI

@MainActor
protocol EditPinLoadedMachineInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditPinLoadedMachineInteractor { }
