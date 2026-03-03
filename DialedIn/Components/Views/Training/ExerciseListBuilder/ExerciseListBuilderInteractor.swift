import SwiftUI

@MainActor
protocol ExerciseListBuilderInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var userExercises: [ExerciseModel] { get }
    var systemExercises: [ExerciseModel] { get }
    var allExercises: [ExerciseModel] { get }
}

extension CoreInteractor: ExerciseListBuilderInteractor { }
