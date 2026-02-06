import SwiftUI

@MainActor
protocol ExpenditureSettingsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ExpenditureSettingsInteractor { }
