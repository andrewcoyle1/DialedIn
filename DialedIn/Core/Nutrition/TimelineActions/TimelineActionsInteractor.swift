import SwiftUI

@MainActor
protocol TimelineActionsInteractor: GlobalInteractor {
    
}

extension CoreInteractor: TimelineActionsInteractor { }
