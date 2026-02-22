import SwiftUI

@MainActor
protocol ExpenditureSettingsInteractor: GlobalInteractor { }

extension CoreInteractor: ExpenditureSettingsInteractor { }
