import SwiftUI

@MainActor
protocol CreateProgramInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: CreateProgramInteractor { }
