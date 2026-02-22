import SwiftUI

@MainActor
protocol NameProgramInteractor: GlobalInteractor { }

extension CoreInteractor: NameProgramInteractor { }
