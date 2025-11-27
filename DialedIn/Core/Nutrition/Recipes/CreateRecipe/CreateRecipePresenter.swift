//
//  CreateRecipePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateRecipePresenter {
    private let interactor: CreateRecipeInteractor
    private let router: CreateRecipeRouter

    var recipeName: String = ""
    var recipeTemplateDescription: String?
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var ingredients: [RecipeIngredientModel] = []
    private(set) var isSaving: Bool = false
    var showAddIngredientModal: Bool = false
    var saveError: String?
    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var canSave: Bool {
        !recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        interactor: CreateRecipeInteractor,
        router: CreateRecipeRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }
    
    func cancel() {
        router.dismissScreen()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onSavePressed() async throws {
        guard !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = currentUser?.userId else {
                isSaving = false
                return
            }
            
            let newRecipe = RecipeTemplateModel(
                id: UUID().uuidString,
                authorId: userId,
                name: recipeName,
                description: recipeTemplateDescription,
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                ingredients: ingredients
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) } ?? generatedImage
            try await interactor.createRecipeTemplate(recipe: newRecipe, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await interactor.createRecipeTemplate(recipe: newRecipe, image: nsImage)
            #endif
            
            // Track created template on the user document
            try await interactor.addCreatedRecipeTemplate(recipeId: newRecipe.id)
            // Auto-bookmark authored templates
            try await interactor.addBookmarkedRecipeTemplate(recipeId: newRecipe.id)
            try await interactor.bookmarkRecipeTemplate(id: newRecipe.id, isBookmarked: true)
            
        } catch {
            
            isSaving = false
            throw error // Re-throw to allow caller to handle the error
        }
        isSaving = false
        router.dismissScreen()
    }
    
    func onAddIngredientPressed() {
        let selectedIngredientsBinding = Binding<[IngredientTemplateModel]>(
            get: { [weak self] in
                guard let self = self else { return [] }
                return self.ingredients.map { $0.ingredient }
            },
            set: { [weak self] newTemplates in
                guard let self = self else { return }
                
                var currentMap = Dictionary(
                    uniqueKeysWithValues: self.ingredients.map {
                        ($0.ingredient.id, $0)
                    }
                )
                
                for tmpl in newTemplates where currentMap[tmpl.id] == nil {
                    currentMap[tmpl.id] = RecipeIngredientModel(
                        ingredient: tmpl,
                        amount: 1
                    )
                }
                
                let newIds = Set(newTemplates.map { $0.id })
                
                currentMap = currentMap.filter { newIds.contains($0.key) }
                
                self.ingredients = Array(currentMap.values)
            }
        )
        
        router.showAddIngredientView(
            delegate: AddIngredientModalDelegate(
                selectedIngredients: selectedIngredientsBinding
            )
        )
    }
    
    func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                interactor.trackEvent(eventName: "AI_Image_Generate_Start", parameters: [
                    "subject": "recipe",
                    "has_name": !recipeName.isEmpty
                ], type: .analytic)
                let imageDescriptionBuilder = ImageDescriptionBuilder(
                    subject: .recipe,
                    mode: .marketingConcise,
                    name: recipeName,
                    description: recipeTemplateDescription,
                    contextNotes: "",
                    desiredStyle: "",
                    backgroundPreference: "",
                    lightingPreference: "",
                    framingNotes: ""
                )
                let prompt = imageDescriptionBuilder.build()
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(eventName: "AI_Image_Generate_Success", parameters: [:], type: .analytic)
            } catch {
                interactor.trackEvent(eventName: "AI_Image_Generate_Fail", parameters: error.eventParameters, type: .severe)
                router.showAlert(error: error)
            }
            isGenerating = false
        }
    }
}
