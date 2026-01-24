import SwiftUI

@MainActor
protocol ExerciseEquipmentRouter: GlobalRouter {
    func showEquipmentPickerView<Item: ResistanceEquipment>(delegate: EquipmentPickerDelegate<Item>)
}

extension CoreRouter: ExerciseEquipmentRouter { }
