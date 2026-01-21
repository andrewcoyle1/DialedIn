import SwiftUI

@MainActor
protocol AddTrainingInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddTrainingInteractor { }
