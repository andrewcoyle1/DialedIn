import SwiftUI

@MainActor
protocol UnitsInteractor: GlobalInteractor { }

extension CoreInteractor: UnitsInteractor { }
