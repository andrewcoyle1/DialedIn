import SwiftUI

@MainActor
protocol EditCableMachineInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditCableMachineInteractor { }
