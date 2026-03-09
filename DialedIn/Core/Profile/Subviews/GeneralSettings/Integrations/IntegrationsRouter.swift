import SwiftUI

@MainActor
protocol IntegrationsRouter: GlobalRouter { }

extension CoreRouter: IntegrationsRouter { }
