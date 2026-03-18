import SwiftUI

@MainActor
protocol ProgramSettingsRouter: GlobalRouter {
    func showRenameProgramView(delegate: RenameWorkoutTemplateModelDelegate)
    func showEditProgramColourIconView(colour: String, icon: String, onSave: @escaping (String, String) -> Void)
    func showEditDayOrderView(dayPlans: [WorkoutTemplateModel], onSave: @escaping ([WorkoutTemplateModel]) -> Void)
    func showEditDeloadView(selected: DeloadType, onSave: @escaping (DeloadType) -> Void)
}

extension CoreRouter: ProgramSettingsRouter {
    func showRenameProgramView(delegate: RenameWorkoutTemplateModelDelegate) {
        router.showScreen(.sheet) { router in
            builder.renameWorkoutTemplateModelView(router: router, delegate: delegate)
                .presentationDetents([.fraction(0.35)])
        }
    }

    func showEditProgramColourIconView(colour: String, icon: String, onSave: @escaping (String, String) -> Void) {
        router.showScreen(.sheet) { router in
            builder.editProgramColourIconView(router: router, colour: colour, icon: icon, onSave: onSave)
                .presentationDetents([.fraction(0.6)])
        }
    }

    func showEditDayOrderView(dayPlans: [WorkoutTemplateModel], onSave: @escaping ([WorkoutTemplateModel]) -> Void) {
        router.showScreen(.sheet) { router in
            builder.editDayOrderView(router: router, dayPlans: dayPlans, onSave: onSave)
                .presentationDetents([.medium, .large])
        }
    }

    func showEditDeloadView(selected: DeloadType, onSave: @escaping (DeloadType) -> Void) {
        router.showScreen(.sheet) { router in
            builder.editDeloadView(router: router, selected: selected, onSave: onSave)
                .presentationDetents([.fraction(0.45)])
        }
    }
}
