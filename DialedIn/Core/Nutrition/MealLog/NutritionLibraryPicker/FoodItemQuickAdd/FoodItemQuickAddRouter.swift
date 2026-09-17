import SwiftUI

@MainActor
protocol FoodItemQuickAddRouter: GlobalRouter {
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: FoodItemQuickAddRouter { }
