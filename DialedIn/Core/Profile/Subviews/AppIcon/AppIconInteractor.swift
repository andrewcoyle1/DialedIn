import SwiftUI

@MainActor
protocol AppIconInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AppIconInteractor { }
