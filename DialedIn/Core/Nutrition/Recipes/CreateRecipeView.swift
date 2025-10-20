//
//  CreateRecipeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateRecipeView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    @Environment(AIManager.self) private var aiManager
    
    @State private var recipeName: String = ""
    @State private var recipeTemplateDescription: String?
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    @State var ingredients: [RecipeIngredientModel] = []

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    @State var isSaving: Bool = false
    private var canSave: Bool {
        !recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @State private var showAddIngredientModal: Bool = false
    @State private var saveError: String?
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var alert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                imageSection
                nameSection
                ingredientTemplatesSection
            }
            .navigationTitle("Create Recipe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        cancel()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                #if DEBUG || MOCK
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            do {
                                try await onSavePressed()
                            } catch {
                                await MainActor.run {
                                    saveError = "Failed to save recipe. Please try again."
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!canSave || isSaving)
                }
            }
            .onChange(of: selectedPhotoItem) {
                guard let newItem = selectedPhotoItem else { return }
                
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                selectedImageData = data
                            }
                        }
                    } catch {
                        
                    }
                }
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView, content: {
                DevSettingsView(viewModel: DevSettingsViewModel(container: container))
            })
            #endif
            .sheet(isPresented: $showAddIngredientModal) {
                AddIngredientModal(selectedIngredients: Binding(get: {
                    ingredients.map { $0.ingredient }
                }, set: { newTemplates in
                    var currentMap = Dictionary(uniqueKeysWithValues: ingredients.map { ($0.ingredient.id, $0) })
                    for tmpl in newTemplates where currentMap[tmpl.id] == nil {
                        currentMap[tmpl.id] = RecipeIngredientModel(ingredient: tmpl, amount: 1)
                    }
                    let newIds = Set(newTemplates.map { $0.id })
                    currentMap = currentMap.filter { newIds.contains($0.key) }
                    ingredients = Array(currentMap.values)
                }))
            }
            .alert("Error", isPresented: .constant(saveError != nil)) {
                Button("OK") {
                    saveError = nil
                }
            } message: {
                Text(saveError ?? "")
            }
            .showCustomAlert(alert: $alert)
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = selectedImageData {
                                #if canImport(UIKit)
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #elseif canImport(AppKit)
                                if let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #endif
                            } else {
                                #if canImport(UIKit)
                                if let generatedImage {
                                    Image(uiImage: generatedImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "tray.fill")
                                        .font(.system(size: 120))
                                        .foregroundStyle(.accent)
                                }
                                #else
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 120))
                                    .foregroundStyle(.accent)
                                #endif
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Recipe Image")
                Spacer()
                Button {
                    onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(isGenerating || recipeName.isEmpty)
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter recipe name", text: $recipeName)
            TextField("Enter recipe description", text: Binding(
                get: { recipeTemplateDescription ?? "" },
                set: { newValue in
                    recipeTemplateDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Recipe name")
        }
    }
    
    private var ingredientTemplatesSection: some View {
        Section {
            if !ingredients.isEmpty {
                ForEach($ingredients) { $wrapper in
                    HStack(alignment: .center, spacing: 12) {
                        CustomListCellView(imageName: wrapper.ingredient.imageURL, title: wrapper.ingredient.name, subtitle: wrapper.ingredient.description)
                        Spacer()
                        HStack(spacing: 6) {
                            TextField("Amount", value: $wrapper.amount, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 70)
                            
                            Picker("", selection: $wrapper.unit) {
                                Text("g").tag(IngredientAmountUnit.grams)
                                Text("ml").tag(IngredientAmountUnit.milliliters)
                                Text("units").tag(IngredientAmountUnit.units)
                            }
                            .pickerStyle(.menu)
                            .frame(width: 15)
                        }
                    }
                    .removeListRowFormatting()
                }
            } else {
                Text("No ingredient templates added yet.")
                    .foregroundStyle(.secondary)
            }
            Button {
                onAddIngredientPressed()
            } label: {
                Text("Add ingredient")
            }
        } header: {
            HStack {
                Text("Ingredients")
                Spacer()
                Button {
                    onAddIngredientPressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }
    
    private func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func onSavePressed() async throws {
        guard !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
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
            try await recipeTemplateManager.createRecipeTemplate(recipe: newRecipe, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await recipeTemplateManager.createRecipeTemplate(recipe: newRecipe, image: nsImage)
            #endif
            
            // Track created template on the user document
            try await userManager.addCreatedRecipeTemplate(recipeId: newRecipe.id)
            // Auto-bookmark authored templates
            try await userManager.addBookmarkedRecipeTemplate(recipeId: newRecipe.id)
            try await recipeTemplateManager.bookmarkRecipeTemplate(id: newRecipe.id, isBookmarked: true)
            
        } catch {
            
            isSaving = false
            throw error // Re-throw to allow caller to handle the error
        }
        isSaving = false
        dismiss()
    }
    
    private func onAddIngredientPressed() {
        showAddIngredientModal = true
    }
    
    private func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                logManager.trackEvent(eventName: "AI_Image_Generate_Start", parameters: [
                    "subject": "recipe",
                    "has_name": !recipeName.isEmpty
                ])
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
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(eventName: "AI_Image_Generate_Success")
            } catch {
                logManager.trackEvent(eventName: "AI_Image_Generate_Fail", parameters: error.eventParameters, type: .severe)
                alert = AnyAppAlert(error: error)
            }
            isGenerating = false
        }
    }
}

#Preview("With Ingredients") {
    @Previewable @State var showingSheet: Bool = true
    Button("Show Sheet") {
        showingSheet = true
    }
    .sheet(isPresented: $showingSheet) {
        CreateRecipeView(ingredients: RecipeIngredientModel.mocks)
    }
    .previewEnvironment()
}

#Preview("Without Ingredients") {
    @Previewable @State var showingSheet: Bool = true
    Button("Show Sheet") {
        showingSheet = true
    }
    .sheet(isPresented: $showingSheet) {
        CreateRecipeView(ingredients: [])
    }
    .previewEnvironment()
}
