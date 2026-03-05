import SwiftUI

@MainActor
protocol FoodLibraryInteractor: GlobalInteractor {
    
}

extension CoreInteractor: FoodLibraryInteractor { }
