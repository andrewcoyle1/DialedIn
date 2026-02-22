import SwiftUI

@MainActor
protocol ProgramIconInteractor: GlobalInteractor {
    var userId: String? { get }
}

extension CoreInteractor: ProgramIconInteractor { }
