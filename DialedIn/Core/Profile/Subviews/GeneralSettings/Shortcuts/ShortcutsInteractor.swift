import SwiftUI

@MainActor
protocol ShortcutsInteractor: GlobalInteractor { }

extension CoreInteractor: ShortcutsInteractor { }
