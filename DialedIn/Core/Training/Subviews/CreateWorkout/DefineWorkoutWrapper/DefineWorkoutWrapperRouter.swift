import SwiftUI

@MainActor
protocol DefineWorkoutWrapperRouter {
    func dismissEnvironment()
}

extension CoreRouter: DefineWorkoutWrapperRouter { }
