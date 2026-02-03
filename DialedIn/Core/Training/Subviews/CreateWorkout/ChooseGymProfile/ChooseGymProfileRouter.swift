import SwiftUI

@MainActor
protocol ChooseGymProfileRouter: GlobalRouter {
    func showDefineWorkoutWrapperView(delegate: DefineWorkoutWrapperDelegate)
}

extension CoreRouter: ChooseGymProfileRouter { }
