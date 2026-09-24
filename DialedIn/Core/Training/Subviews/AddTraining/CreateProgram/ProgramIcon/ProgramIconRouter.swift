import SwiftUI

@MainActor
protocol ProgramIconRouter: GlobalRouter {
    func showProgramDesignView(delegate: ProgramDesignDelegate)
}

extension CoreRouter: ProgramIconRouter { }
