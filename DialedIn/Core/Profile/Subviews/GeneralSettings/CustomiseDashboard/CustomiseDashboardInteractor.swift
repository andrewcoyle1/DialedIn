import SwiftUI

@MainActor
protocol CustomiseDashboardInteractor: GlobalInteractor { }

extension CoreInteractor: CustomiseDashboardInteractor { }
