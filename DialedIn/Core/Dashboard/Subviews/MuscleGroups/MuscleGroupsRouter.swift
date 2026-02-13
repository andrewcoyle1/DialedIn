import SwiftUI

@MainActor
protocol MuscleGroupsRouter: GlobalRouter {
    func showMuscleGroupDetailView(muscle: Muscles, delegate: MuscleGroupDetailDelegate, themeColor: Color?)
}

extension CoreRouter: MuscleGroupsRouter { }
