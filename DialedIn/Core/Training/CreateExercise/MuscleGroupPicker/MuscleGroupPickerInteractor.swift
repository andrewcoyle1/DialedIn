import SwiftUI

@MainActor
protocol MuscleGroupPickerInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: MuscleGroupPickerInteractor { }
