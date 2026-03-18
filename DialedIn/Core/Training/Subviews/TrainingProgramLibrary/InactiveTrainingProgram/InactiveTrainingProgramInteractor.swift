import SwiftUI

@MainActor
protocol InactiveTrainingProgramInteractor: GlobalInteractor { }

extension CoreInteractor: InactiveTrainingProgramInteractor { }
