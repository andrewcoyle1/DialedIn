import SwiftUI

@MainActor
protocol EditLoadableAccessoryInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditLoadableAccessoryInteractor { }
