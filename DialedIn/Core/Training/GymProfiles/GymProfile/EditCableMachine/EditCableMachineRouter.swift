import SwiftUI

@MainActor
protocol EditCableMachineRouter: GlobalRouter {
    func showEditWeightRangeView<Range: WeightRange>(delegate: EditWeightRangeDelegate<Range>)
}

extension CoreRouter: EditCableMachineRouter { }
