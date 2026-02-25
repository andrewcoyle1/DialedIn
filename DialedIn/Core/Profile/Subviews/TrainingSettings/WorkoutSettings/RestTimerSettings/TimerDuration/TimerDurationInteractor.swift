import SwiftUI

@MainActor
protocol TimerDurationInteractor: GlobalInteractor {
    
}

extension CoreInteractor: TimerDurationInteractor { }
