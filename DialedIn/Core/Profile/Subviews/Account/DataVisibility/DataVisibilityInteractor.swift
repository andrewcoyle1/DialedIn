import SwiftUI

@MainActor
protocol DataVisibilityInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DataVisibilityInteractor { }
