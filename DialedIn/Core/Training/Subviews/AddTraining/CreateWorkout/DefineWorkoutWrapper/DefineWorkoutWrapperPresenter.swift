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
            imageURL: nil,
            dateCreated: Date.now,
            dateModified: Date.now,
            exercises: exercises
        )
        
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
