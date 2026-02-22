//
//  CreateIngredientInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol CreateIngredientInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: CreateIngredientInteractor { }
