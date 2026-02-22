import SwiftUI

@MainActor
protocol DataVisibilityInteractor: GlobalInteractor { }

extension CoreInteractor: DataVisibilityInteractor { }
