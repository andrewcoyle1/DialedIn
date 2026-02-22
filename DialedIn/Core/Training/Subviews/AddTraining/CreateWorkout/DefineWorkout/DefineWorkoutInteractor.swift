import SwiftUI

@MainActor
protocol DefineWorkoutInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws 
}

extension CoreInteractor: DefineWorkoutInteractor { }
