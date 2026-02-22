import SwiftUI

@MainActor
protocol CreateProgramInteractor: GlobalInteractor { }

extension CoreInteractor: CreateProgramInteractor { }
