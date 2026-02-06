import SwiftUI

@MainActor
protocol HabitsRouter: GlobalRouter {
    
}

extension CoreRouter: HabitsRouter { }
