import SwiftUI

@MainActor
protocol ProgramSettingsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramSettingsInteractor { }
