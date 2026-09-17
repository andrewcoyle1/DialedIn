import SwiftUI

@MainActor
protocol TimelineActionsRouter: GlobalRouter {
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: TimelineActionsRouter { }
