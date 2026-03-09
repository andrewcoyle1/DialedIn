import SwiftUI

@MainActor
protocol WorkoutCompletedRouter: GlobalRouter {
    
}

extension CoreRouter: WorkoutCompletedRouter { }
