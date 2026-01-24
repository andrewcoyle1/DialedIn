import SwiftUI

@MainActor
protocol EnumPickerInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EnumPickerInteractor { }
