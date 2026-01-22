import SwiftUI

@MainActor
protocol EditPinLoadedMachineRouter: GlobalRouter {
    func showEditWeightRangeView<Range: WeightRange>(delegate: EditWeightRangeDelegate<Range>)
}

extension CoreRouter: EditPinLoadedMachineRouter { }
