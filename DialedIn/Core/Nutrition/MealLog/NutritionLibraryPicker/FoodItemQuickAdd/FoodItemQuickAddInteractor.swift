import SwiftUI

@MainActor
protocol FoodItemQuickAddInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func saveMeal(_ meal: MealLogModel) async throws
}

extension CoreInteractor: FoodItemQuickAddInteractor { }
