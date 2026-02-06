import SwiftUI

@MainActor
protocol IntegrationsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: IntegrationsInteractor { }
