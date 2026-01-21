import SwiftUI

@MainActor
protocol GymProfileRouter: GlobalRouter {
    func showEditFreeWeightView(freeWeight: Binding<FreeWeights>)
}

extension CoreRouter: GymProfileRouter { }
