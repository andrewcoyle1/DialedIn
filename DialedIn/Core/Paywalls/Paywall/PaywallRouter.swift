import SwiftUI

@MainActor
protocol PaywallRouter: OnboardingStepRouter { }

extension CoreRouter: PaywallRouter { }
