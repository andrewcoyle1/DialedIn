import SwiftUI

@MainActor
protocol CustomiseDashboardInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: CustomiseDashboardInteractor { }
