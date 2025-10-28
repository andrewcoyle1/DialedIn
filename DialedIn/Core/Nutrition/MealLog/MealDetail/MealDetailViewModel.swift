//
//  MealDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

protocol MealDetailInteractor {

}

extension CoreInteractor: MealDetailInteractor { }

@Observable
@MainActor
class MealDetailViewModel {
    private let interactor: MealDetailInteractor
    let meal: MealLogModel

    init(
        interactor: MealDetailInteractor,
        meal: MealLogModel
    ) {
        self.interactor = interactor
        self.meal = meal
    }
}
