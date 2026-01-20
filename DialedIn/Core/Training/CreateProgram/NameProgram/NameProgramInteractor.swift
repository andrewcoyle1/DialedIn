import SwiftUI

@MainActor
protocol NameProgramInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: NameProgramInteractor { }
