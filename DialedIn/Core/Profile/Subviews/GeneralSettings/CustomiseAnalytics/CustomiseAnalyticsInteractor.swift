import SwiftUI

@MainActor
protocol CustomiseAnalyticsInteractor: GlobalInteractor { }

extension CoreInteractor: CustomiseAnalyticsInteractor { }
