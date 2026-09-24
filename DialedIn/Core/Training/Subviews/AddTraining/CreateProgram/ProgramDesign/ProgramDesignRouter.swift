import SwiftUI

@MainActor
protocol ProgramDesignRouter: GlobalRouter {
    func showRenameWorkoutTemplateModelView(delegate: RenameWorkoutTemplateModelDelegate)
    func showProgramSettingsView(program: Binding<TrainingProgram>)
}

extension CoreRouter: ProgramDesignRouter { }

extension CoreRouter {
    func showRenameWorkoutTemplateModelView(delegate: RenameWorkoutTemplateModelDelegate) {
        router.showScreen(.sheet) { router in
            builder.renameWorkoutTemplateModelView(router: router, delegate: delegate)
                .presentationDetents([.fraction(0.8)])
        }
    }
}
