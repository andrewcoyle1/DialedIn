import SwiftUI

@MainActor
protocol ProgramDesignRouter {
    func showRenameDayPlanView(delegate: RenameDayPlanDelegate)
    func showProgramSettingsView(program: Binding<TrainingProgram>)
    func showAddExercisesView(delegate: AddExerciseModalDelegate)
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
