import SwiftUI

@MainActor
protocol NameProgramRouter {
    func showProgramIconView(delegate: ProgramIconDelegate)
}

extension CoreRouter: NameProgramRouter { }
