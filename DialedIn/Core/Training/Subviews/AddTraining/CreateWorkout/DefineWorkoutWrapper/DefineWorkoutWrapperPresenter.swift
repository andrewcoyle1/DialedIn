import SwiftUI

@Observable
@MainActor
class DefineWorkoutWrapperPresenter {
    
    private let interactor: DefineWorkoutWrapperInteractor
    private let router: DefineWorkoutWrapperRouter
    
    var exercises: [WorkoutTemplateExercise]
    private(set) var isSaving: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }

    /// An empty template starts a workout with nothing to do, and a second tap mid-save wrote it twice.
    var canSave: Bool {
        !exercises.isEmpty && !isSaving
    }
    
    init(
        interactor: DefineWorkoutWrapperInteractor,
        router: DefineWorkoutWrapperRouter,
        exercises: [WorkoutTemplateExercise] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.exercises = exercises
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func onConfirmPressed(delegate: DefineWorkoutWrapperDelegate) {
        guard canSave else { return }
        // Reachable: the user document arrives on the sync engine's own task. A silent return threw
        // the whole wizard away.
        guard let uid = currentUser?.userId else {
            router.showSimpleAlert(title: "Unable to Save Workout", subtitle: "Please try again.")
            return
        }
        let existing = delegate.workoutTemplate
        let workout = WorkoutTemplateModel(
            id: existing?.id ?? UUID().uuidString,
            authorId: existing?.authorId ?? uid,
            name: delegate.name,
            description: existing?.description,
            gymProfileId: delegate.gymProfile.id,
            imageURL: existing?.imageURL,
            dateCreated: existing?.dateCreated ?? Date.now,
            dateModified: Date.now,
            exercises: exercises
        )

        if let onWorkoutCreated = delegate.onWorkoutCreated {
            router.showAlert(
                title: "Save Workout?",
                subtitle: "Would you like to save this workout template to your library?",
                buttons: {
                    AnyView(
                        HStack {
                            Button("No") {
                                Task { @MainActor in
                                    self.finishWithoutSaving(workout: workout, onWorkoutCreated: onWorkoutCreated)
                                }
                            }

                            Button("Yes") {
                                Task { @MainActor in
                                    await self.saveThenFinish(workout: workout, onWorkoutCreated: onWorkoutCreated)
                                }
                            }
                        }
                    )
                }
            )
        } else {
            // Dismissing before the save returned tore the failure alert down with the screen.
            // The flag is raised here, not in the task, so a second tap on the same tick is refused.
            isSaving = true
            Task { @MainActor in
                await saveThenFinish(workout: workout, onWorkoutCreated: nil)
            }
        }
    }

    /// The user answered "Yes" to saving the workout to their library, so persist it and only then start it.
    /// If the save fails we stay on the screen with the failure alert rather than dismissing out from
    /// under it — otherwise the alert is torn down before it can be read and the template is silently lost.
    private func saveThenFinish(
        workout: WorkoutTemplateModel,
        onWorkoutCreated: (@Sendable (WorkoutTemplateModel) -> Void)?
    ) async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await interactor.saveWorkoutTemplate(workoutTemplate: workout, image: nil)
        } catch {
            router.showSimpleAlert(title: "Unable to Save Workout", subtitle: "Please try again.")
            return
        }
        finishWithoutSaving(workout: workout, onWorkoutCreated: onWorkoutCreated)
    }

    /// The user answered "No", so start the workout without adding it to the library.
    private func finishWithoutSaving(
        workout: WorkoutTemplateModel,
        onWorkoutCreated: (@Sendable (WorkoutTemplateModel) -> Void)?
    ) {
        router.dismissEnvironment()
        onWorkoutCreated?(workout)
    }

}

extension DefineWorkoutWrapperPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "DefineWorkoutWrapperView_Appear"
            case .onDisappear: return "DefineWorkoutWrapperView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
