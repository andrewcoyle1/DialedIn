import SwiftUI

@MainActor
protocol MuscleGroupsInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: MuscleGroupsInteractor { }
