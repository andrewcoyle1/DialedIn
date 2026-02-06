import SwiftUI

@MainActor
protocol ExerciseSaveInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws 
}

extension CoreInteractor: ExerciseSaveInteractor { }
