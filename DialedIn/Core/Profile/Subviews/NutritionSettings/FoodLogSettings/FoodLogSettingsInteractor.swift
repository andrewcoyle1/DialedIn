import SwiftUI

@MainActor
protocol FoodLogSettingsInteractor: GlobalInteractor { }

extension CoreInteractor: FoodLogSettingsInteractor { }
