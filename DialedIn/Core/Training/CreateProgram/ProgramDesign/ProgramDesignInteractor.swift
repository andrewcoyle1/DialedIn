import SwiftUI

@MainActor
protocol ProgramDesignInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramDesignInteractor { }
