//
//  CreateFoodInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol CreateFoodInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func saveIngredientTemplate(_ ingredient: IngredientTemplateModel, image: PlatformImage?) async throws
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: CreateFoodInteractor { }
