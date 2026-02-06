import SwiftUI

@MainActor
protocol EditPlateLoadedMachineInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditPlateLoadedMachineInteractor { }
