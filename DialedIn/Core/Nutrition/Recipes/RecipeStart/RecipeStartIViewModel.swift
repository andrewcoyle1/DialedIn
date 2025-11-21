//
//  RecipeStartViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/11/2025.
//

import Foundation

protocol RecipeStartInteractor {

}

extension CoreInteractor: RecipeStartInteractor { }

@MainActor
protocol RecipeStartRouter {

}

extension CoreRouter: RecipeStartRouter { }

@Observable
@MainActor
class RecipeStartViewModel {
    private let interactor: RecipeStartInteractor
    private let router: RecipeStartRouter

    init(
        interactor: RecipeStartInteractor,
        router: RecipeStartRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

}
