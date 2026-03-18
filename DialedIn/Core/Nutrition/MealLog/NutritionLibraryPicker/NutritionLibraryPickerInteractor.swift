//
//  NutritionLibraryPickerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NutritionLibraryPickerInteractor: GlobalInteractor {
    var foods: [FoodModel] { get }
    func saveExternalFood(_ food: FoodModel) async
}

extension CoreInteractor: NutritionLibraryPickerInteractor {
    func saveExternalFood(_ food: FoodModel) async {
        guard let uid = userId else { return }
        let owned = food.withAuthorId(uid)
        try? await saveFood(owned, image: nil)
    }
}
