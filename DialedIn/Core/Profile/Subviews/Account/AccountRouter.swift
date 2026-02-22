import SwiftUI

@MainActor
protocol AccountRouter: GlobalRouter {
    func showDataVisibilityView(delegate: DataVisibilityDelegate)
    func switchToOnboardingModule()
}

extension CoreRouter: AccountRouter { }
