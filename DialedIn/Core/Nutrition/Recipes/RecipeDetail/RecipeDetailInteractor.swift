//
//  RecipeDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol RecipeDetailInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: RecipeDetailInteractor { }
