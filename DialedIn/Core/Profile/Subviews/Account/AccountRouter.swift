import SwiftUI

@MainActor
protocol AccountRouter: GlobalRouter {
    
}

extension CoreRouter: AccountRouter { }
