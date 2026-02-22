import SwiftUI

@MainActor
protocol CorePaywallRouter: GlobalRouter { }

extension CoreRouter: CorePaywallRouter { }
