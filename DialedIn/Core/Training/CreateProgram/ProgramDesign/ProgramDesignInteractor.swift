import SwiftUI

@MainActor
protocol ProgramDesignInteractor {
    var userId: String? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramDesignInteractor { }
