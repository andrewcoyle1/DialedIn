import SwiftUI

@MainActor
protocol OnbPaywallRouter: GlobalRouter {
    func showOnboardingCompleteAccountSetupView()
}

extension CoreRouter: OnbPaywallRouter { }
