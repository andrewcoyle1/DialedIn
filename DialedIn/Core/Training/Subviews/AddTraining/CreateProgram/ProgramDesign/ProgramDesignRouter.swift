import SwiftUI

@MainActor
protocol ProgramDesignRouter: GlobalRouter {
    func showRenameWorkoutTemplateModelView(delegate: RenameWorkoutTemplateModelDelegate)
    func showProgramSettingsView(program: Binding<TrainingProgram>)
    func showExercisePickerView(delegate: ExercisePickerDelegate)
    func showCompleteAccountSetupView()
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
    func showGoalSettingView()
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate)
    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate)
    func showCustomisingDietProgramView()
    func showOnboardingCompletedView()
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
