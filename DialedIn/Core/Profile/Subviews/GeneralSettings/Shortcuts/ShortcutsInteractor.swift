import SwiftUI

@MainActor
protocol ShortcutsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ShortcutsInteractor { }
