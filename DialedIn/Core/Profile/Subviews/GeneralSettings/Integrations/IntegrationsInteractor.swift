import SwiftUI

@MainActor
protocol IntegrationsInteractor: GlobalInteractor { }

extension CoreInteractor: IntegrationsInteractor { }
