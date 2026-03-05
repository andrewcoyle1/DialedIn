import SwiftUI

@MainActor
protocol FoodLibraryRouter: GlobalRouter { }

extension CoreRouter: FoodLibraryRouter { }
