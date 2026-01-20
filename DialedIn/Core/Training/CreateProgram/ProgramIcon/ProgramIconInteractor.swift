import SwiftUI

@MainActor
protocol ProgramIconInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramIconInteractor { }
