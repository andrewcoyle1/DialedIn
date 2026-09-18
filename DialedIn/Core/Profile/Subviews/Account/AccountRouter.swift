import SwiftUI

@MainActor
protocol AccountRouter: GlobalRouter {
    func switchToOnboardingModule()
}

extension CoreRouter: AccountRouter { }
