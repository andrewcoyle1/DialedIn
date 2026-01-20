import SwiftUI

@MainActor
protocol ProgramIconRouter {
    func showProgramDesignView(delegate: ProgramDesignDelegate)
}

extension CoreRouter: ProgramIconRouter { }
