import SwiftUI

@MainActor
protocol ExerciseSaveInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: ExerciseSaveInteractor { }
