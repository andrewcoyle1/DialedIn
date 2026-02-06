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
    
    func onConfirmPressed(delegate: DefineWorkoutWrapperDelegate) {
        guard let uid = currentUser?.userId else { return }
        let workout = WorkoutTemplateModel(
            authorId: uid,
            name: delegate.name,
            description: nil,
            imageURL: nil,
            isSystemWorkout: false,
            dateCreated: Date.now,
            dateModified: Date.now,
            exercises: exercises,
            clickCount: 0,
            bookmarkCount: 0,
            favouriteCount: 0
        )
        
        defer {
            router.dismissEnvironment()
        }
        
        Task {
            do {
                try await interactor.createWorkoutTemplate(workout: workout, image: nil)
            } catch {
                router.showSimpleAlert(title: "Unable to Create Workout", subtitle: "Please try again.")
            }
        }
    }
}
