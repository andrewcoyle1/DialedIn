//
//  CreateRecipeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct CreateRecipeView: View {

    @State var presenter: CreateRecipePresenter

    var body: some View {
        List {
            imageSection
            nameSection
            ingredientTemplatesSection
        }
        .navigationTitle("Create Recipe")
        .toolbar {
            toolbarContent
        }
        .onChange(of: presenter.selectedPhotoItem) {
            guard let newItem = presenter.selectedPhotoItem else { return }

            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            presenter.selectedImageData = data
                        }
                    }
                } catch {

                }
            }
        }
        .alert("Error", isPresented: .constant(presenter.saveError != nil)) {
            Button("OK") {
                presenter.saveError = nil
            }
        } message: {
            Text(presenter.saveError ?? "")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    presenter.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = presenter.selectedImageData {
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
                                if let generatedImage = presenter.generatedImage {
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
                .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Recipe Image")
                Spacer()
                Button {
                    presenter.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(presenter.isGenerating || presenter.recipeName.isEmpty)
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter recipe name", text: $presenter.recipeName)
            TextField("Enter recipe description", text: Binding(
                get: { presenter.recipeTemplateDescription ?? "" },
                set: { newValue in
                    presenter.recipeTemplateDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Recipe name")
        }
    }
    
    private var ingredientTemplatesSection: some View {
        Section {
            if !presenter.ingredients.isEmpty {
                ForEach($presenter.ingredients) { $wrapper in
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
                presenter.onAddIngredientPressed()
            } label: {
                Text("Add ingredient")
            }
        } header: {
            HStack {
                Text("Ingredients")
                Spacer()
                Button {
                    presenter.onAddIngredientPressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.cancel()
            } label: {
                Image(systemName: "xmark")
            }
        }
        #if DEBUG || MOCK
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    do {
                        try await presenter.onSavePressed()
                    } catch {
                        await MainActor.run {
                            presenter.saveError = "Failed to save recipe. Please try again."
                        }
                    }
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSave || presenter.isSaving)
        }
    }
}

#Preview("With Ingredients") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.createRecipeView(router: router)
    }
    .previewEnvironment()
}

#Preview("Without Ingredients") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.createRecipeView(router: router)
    }
    .previewEnvironment()
}
