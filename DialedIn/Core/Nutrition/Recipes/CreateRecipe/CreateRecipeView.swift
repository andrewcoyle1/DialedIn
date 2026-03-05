//
//  CreateRecipeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateRecipeView: View {
    
    @State var presenter: CreateRecipePresenter
    
    var body: some View {
        List {
            nameSection
            ingredientTemplatesSection
        }
        .navigationTitle("Create Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onNextPressed()
            } label: {
                Text("Next")
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter recipe name", text: $presenter.recipeName)
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
                presenter.onDismissPressed()
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
    }
}

extension CoreBuilder {
    func createRecipeView(router: AnyRouter) -> some View {
        CreateRecipeView(
            presenter: CreateRecipePresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
    }
}

extension CoreRouter {
    func showCreateRecipeView() {
        router.showScreen(.sheet) { router in
            builder.createRecipeView(router: router)
        }
    }
}

#Preview("With Ingredients") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        builder.createRecipeView(router: router)
    }
    
}

#Preview("Without Ingredients") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        builder.createRecipeView(router: router)
    }
    
}
