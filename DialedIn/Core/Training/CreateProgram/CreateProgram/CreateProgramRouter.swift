import SwiftUI

@MainActor
protocol CreateProgramRouter: GlobalRouter {
    func showNameProgramView(delegate: NameProgramDelegate)
}

extension CoreRouter: CreateProgramRouter { }
