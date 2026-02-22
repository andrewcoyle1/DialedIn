import SwiftUI

@MainActor
protocol DefineWorkoutWrapperInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws
}

extension CoreInteractor: DefineWorkoutWrapperInteractor { }
