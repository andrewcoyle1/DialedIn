import SwiftUI

@MainActor
protocol ExerciseEquipmentRouter: GlobalRouter {
    func showEquipmentPickerView(delegate: EquipmentPickerDelegate)
}

extension CoreRouter: ExerciseEquipmentRouter { }
