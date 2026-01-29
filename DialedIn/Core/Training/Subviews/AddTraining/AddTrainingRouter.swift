import SwiftUI

@MainActor
protocol AddTrainingRouter: GlobalRouter {
    func showCreateProgramView(delegate: CreateProgramDelegate)
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)
    
}

extension CoreRouter: AddTrainingRouter { }
