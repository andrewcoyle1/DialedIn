import SwiftUI

@MainActor
protocol StrategySettingsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: StrategySettingsInteractor { }
