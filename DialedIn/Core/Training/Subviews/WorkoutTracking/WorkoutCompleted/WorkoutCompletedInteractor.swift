import SwiftUI

@MainActor
protocol WorkoutCompletedInteractor: GlobalInteractor {
    
}

extension CoreInteractor: WorkoutCompletedInteractor { }
