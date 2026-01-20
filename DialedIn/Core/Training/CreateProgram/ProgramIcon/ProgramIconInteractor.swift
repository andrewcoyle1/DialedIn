import SwiftUI

@MainActor
protocol ProgramIconInteractor {
    var userId: String? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramIconInteractor { }
