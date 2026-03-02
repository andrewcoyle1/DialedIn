//
//  CreateRecipeInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol CreateRecipeInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func saveRecipeTemplate(_ recipe: RecipeTemplateModel, image: PlatformImage?) async throws
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: CreateRecipeInteractor { }
