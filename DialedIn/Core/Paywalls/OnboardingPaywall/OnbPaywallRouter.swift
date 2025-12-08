import SwiftUI

@MainActor
protocol OnbPaywallRouter: GlobalRouter {
    func showOnboardingCompleteAccountSetupView()
}

extension OnbRouter: OnbPaywallRouter { }
