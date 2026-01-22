import SwiftUI

@MainActor
protocol AddLoadableBarInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AddLoadableBarInteractor { }
