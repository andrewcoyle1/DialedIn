import SwiftUI

@MainActor
protocol EquipmentPickerInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EquipmentPickerInteractor { }
