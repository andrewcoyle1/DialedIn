//
//  CreateRecipeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateRecipeView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: CreateRecipeViewModel

    @ViewBuilder var devSettingsView: () -> AnyView
    @ViewBuilder var addIngredientModalView: (AddIngredientModalViewDelegate) -> AnyView

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
                        viewModel.cancel(onDismiss: {
                            dismiss()
                        })
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                #if DEBUG || MOCK
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            do {
                                try await viewModel.onSavePressed(onDismiss: { dismiss() })
                            } catch {
                                await MainActor.run {
                                    viewModel.saveError = "Failed to save recipe. Please try again."
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) {
                guard let newItem = viewModel.selectedPhotoItem else { return }
                
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                viewModel.selectedImageData = data
                            }
                        }
                    } catch {
                        
                    }
                }
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView, content: {
                devSettingsView()
            })
            #endif
            .sheet(isPresented: $viewModel.showAddIngredientModal) {
                addIngredientModalView(
                    AddIngredientModalViewDelegate(
                        selectedIngredients: Binding(
                            get: {
                                viewModel.ingredients.map {
                                    $0.ingredient
                                }
                            },
                            set: { newTemplates in
                                var currentMap = Dictionary(
                                    uniqueKeysWithValues: viewModel.ingredients.map {
                                        (
                                            $0.ingredient.id,
                                            $0
                                        )
                                    })
                                for tmpl in newTemplates where currentMap[tmpl.id] == nil {
                                    currentMap[tmpl.id] = RecipeIngredientModel(
                                        ingredient: tmpl,
                                        amount: 1
                                    )
                                }
                                let newIds = Set(
                                    newTemplates.map {
                                        $0.id
                                    })
                                currentMap = currentMap.filter {
                                    newIds.contains(
                                        $0.key
                                    )
                                }
                                viewModel.ingredients = Array(
                                    currentMap.values
                                )
                            }
                        )
                    )
                )
            }
            .alert("Error", isPresented: .constant(viewModel.saveError != nil)) {
                Button("OK") {
                    viewModel.saveError = nil
                }
            } message: {
                Text(viewModel.saveError ?? "")
            }
            .showCustomAlert(alert: $viewModel.alert)
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    viewModel.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = viewModel.selectedImageData {
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
                                if let generatedImage = viewModel.generatedImage {
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
                .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Recipe Image")
                Spacer()
                Button {
                    viewModel.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(viewModel.isGenerating || viewModel.recipeName.isEmpty)
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter recipe name", text: $viewModel.recipeName)
            TextField("Enter recipe description", text: Binding(
                get: { viewModel.recipeTemplateDescription ?? "" },
                set: { newValue in
                    viewModel.recipeTemplateDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Recipe name")
        }
    }
    
    private var ingredientTemplatesSection: some View {
        Section {
            if !viewModel.ingredients.isEmpty {
                ForEach($viewModel.ingredients) { $wrapper in
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
                viewModel.onAddIngredientPressed()
            } label: {
                Text("Add ingredient")
            }
        } header: {
            HStack {
                Text("Ingredients")
                Spacer()
                Button {
                    viewModel.onAddIngredientPressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }
}

#Preview("With Ingredients") {
    @Previewable @State var showingSheet: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container)

    Button("Show Sheet") {
        showingSheet = true
    }
    .sheet(isPresented: $showingSheet) {
        builder.createRecipeView()
    }
    .previewEnvironment()
}

#Preview("Without Ingredients") {
    @Previewable @State var showingSheet: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container)

    Button("Show Sheet") {
        showingSheet = true
    }
    .sheet(isPresented: $showingSheet) {
        builder.createRecipeView()
    }
    .previewEnvironment()
}
