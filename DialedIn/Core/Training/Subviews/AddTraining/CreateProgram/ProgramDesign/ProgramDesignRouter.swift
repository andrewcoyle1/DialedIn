import SwiftUI

@MainActor
protocol ProgramDesignRouter: GlobalRouter {
    func showRenameDayPlanView(delegate: RenameDayPlanDelegate)
    func showProgramSettingsView(program: Binding<TrainingProgram>)
    func showExercisePickerView(delegate: ExercisePickerDelegate)
}

extension CoreRouter: ProgramDesignRouter { }

extension CoreRouter {
    func showRenameDayPlanView(delegate: RenameDayPlanDelegate) {
        router.showScreen(.sheet) { router in
            builder.renameDayPlanView(router: router, delegate: delegate)
                .presentationDetents([.fraction(0.8)])
        }
    }
}
