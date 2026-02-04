import SwiftUI

@MainActor
protocol DefineWorkoutInteractor {
    var currentUser: UserModel? { get }
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws 
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DefineWorkoutInteractor { }
