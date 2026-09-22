import SwiftUI

@MainActor
protocol AccountRouter: GlobalRouter {
    func switchToOnboardingModule()
    /// For upgrading an anonymous account — the same screen onboarding uses.
    func showAuthView()
}

extension CoreRouter: AccountRouter { }
