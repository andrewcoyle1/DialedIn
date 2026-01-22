import SwiftUI

@MainActor
protocol EditLoadableBarInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditLoadableBarInteractor { }
