import SwiftUI

@MainActor
protocol AccountRouter: GlobalRouter {
    func showDataVisibilityView(delegate: DataVisibilityDelegate)
}

extension CoreRouter: AccountRouter { }
