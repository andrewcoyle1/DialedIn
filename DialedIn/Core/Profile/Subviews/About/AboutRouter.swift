import SwiftUI

@MainActor
protocol AboutRouter: GlobalRouter {
    
}

extension CoreRouter: AboutRouter { }
