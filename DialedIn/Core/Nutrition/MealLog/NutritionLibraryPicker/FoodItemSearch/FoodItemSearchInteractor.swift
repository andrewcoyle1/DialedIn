import SwiftUI

@MainActor
protocol FoodItemSearchInteractor: GlobalInteractor {
    
}

extension CoreInteractor: FoodItemSearchInteractor { }
