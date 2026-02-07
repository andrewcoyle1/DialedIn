import SwiftUI

@MainActor
protocol MuscleGroupsRouter: GlobalRouter {
    func showMuscleGroupDetailView(muscle: Muscles, delegate: MuscleGroupDetailDelegate)
}

extension CoreRouter: MuscleGroupsRouter { }
