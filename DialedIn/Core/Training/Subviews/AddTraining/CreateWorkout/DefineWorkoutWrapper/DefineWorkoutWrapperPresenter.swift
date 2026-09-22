import SwiftUI

@Observable
@MainActor
class DefineWorkoutWrapperPresenter {
    
    private let interactor: DefineWorkoutWrapperInteractor
    private let router: DefineWorkoutWrapperRouter
    
    var exercises: [WorkoutTemplateExercise] = []

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(interactor: DefineWorkoutWrapperInteractor, router: DefineWorkoutWrapperRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func onConfirmPressed(delegate: DefineWorkoutWrapperDelegate) {
        guard let uid = currentUser?.userId else { return }
        let workout = WorkoutTemplateModel(
            authorId: uid,
            name: delegate.name,
            description: nil,
            gymProfileId: delegate.gymProfile.id,
            imageURL: nil,
            dateCreated: Date.now,
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
            defer {
                router.dismissEnvironment()
            }
            Task {
                do {
                    try await interactor.saveWorkoutTemplate(workoutTemplate: workout, image: nil)
                } catch {
                    router.showSimpleAlert(title: "Unable to Create Workout", subtitle: "Please try again.")
                }
            }
        }
    }

    /// The user answered "Yes" to saving the workout to their library, so persist it and only then start it.
    /// If the save fails we stay on the screen with the failure alert rather than dismissing out from
    /// under it — otherwise the alert is torn down before it can be read and the template is silently lost.
    private func saveThenFinish(
        workout: WorkoutTemplateModel,
        onWorkoutCreated: @escaping @Sendable (WorkoutTemplateModel) -> Void
    ) async {
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
        onWorkoutCreated: @escaping @Sendable (WorkoutTemplateModel) -> Void
    ) {
        router.dismissEnvironment()
        onWorkoutCreated(workout)
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
