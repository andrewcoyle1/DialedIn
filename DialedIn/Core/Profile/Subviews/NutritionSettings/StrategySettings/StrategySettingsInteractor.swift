import SwiftUI

@MainActor
protocol StrategySettingsInteractor: GlobalInteractor { }

extension CoreInteractor: StrategySettingsInteractor { }
