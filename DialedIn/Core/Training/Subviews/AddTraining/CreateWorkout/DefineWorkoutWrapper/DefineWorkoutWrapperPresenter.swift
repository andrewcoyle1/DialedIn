import SwiftUI

@Observable
@MainActor
class DefineWorkoutWrapperPresenter {
    
    private let interactor: DefineWorkoutWrapperInteractor
    private let router: DefineWorkoutWrapperRouter
    
    var exercises: [WorkoutTemplateExercise] = []
    var saveToLibrary: Bool = false

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
                            Button("No") { self.saveToLibrary = false }
                            
                            Button("Yes") { self.saveToLibrary = true }
                        }
                    )
                }
            )
            if saveToLibrary {
                Task {
                    do {
                        try await interactor.saveWorkoutTemplate(workoutTemplate: workout, image: nil)
                    } catch {
                        router.showSimpleAlert(title: "Unable to Save Workout", subtitle: "Please try again.")
                    }
                }
            }
            router.dismissEnvironment()
            onWorkoutCreated(workout)
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
