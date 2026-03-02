//
//  SetTrackerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

import SwiftUI

@MainActor
protocol SetTrackerRouter: GlobalRouter {
    func showWorkoutExerciseEquipmentSheetView(delegate: WorkoutExerciseEquipmentSheetDelegate)
    func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void)
    func showRestModal(
        primaryButtonAction: @escaping () -> Void,
        secondaryButtonAction: @escaping () -> Void,
        minutesSelection: Binding<Int>,
        secondsSelection: Binding<Int>
    )
}

extension CoreRouter: SetTrackerRouter { }
