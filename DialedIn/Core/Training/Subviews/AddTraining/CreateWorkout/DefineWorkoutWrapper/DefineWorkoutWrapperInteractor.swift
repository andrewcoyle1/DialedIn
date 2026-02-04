import SwiftUI

@MainActor
protocol DefineWorkoutWrapperInteractor {
    var currentUser: UserModel? { get }
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DefineWorkoutWrapperInteractor { }
