//
//  AddFoodView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct AddFoodView: View {

    @State var presenter: AddFoodPresenter

    var delegate: AddFoodDelegate

    private var filteredIngredients: [FoodModel] {
        let query = presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return presenter.foods }
        return presenter.foods.filter { ingredient in
            var fields: [String] = [
                ingredient.name
            ]
            if let description = ingredient.description { fields.append(description) }
            return fields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredIngredients) { ingredient in
                CustomListCellView(imageName: ingredient.imageURL, title: ingredient.name, subtitle: ingredient.description, isSelected: delegate.selectedIngredients.contains(where: { $0.id == ingredient.id }))
                    .anyButton {
                        presenter.onIngredientPressed(ingredient: ingredient, selectedIngredients: &delegate.selectedIngredients.wrappedValue)
                    }
                    .removeListRowFormatting()
            }
        }
        .scrollIndicators(.hidden)
        .searchable(text: $presenter.searchText)
        .navigationTitle("Add Ingredients")
        .navigationSubtitle("Select one or more ingredients to add")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

extension CoreBuilder {
    func addFoodView(router: AnyRouter, delegate: AddFoodDelegate) -> some View {
        AddFoodView(
            presenter: AddFoodPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showAddIngredientView(delegate: AddFoodDelegate) {
        router.showScreen(.sheet) { router in
            builder.addFoodView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    @Previewable @State var selectedIngredients: [FoodModel] = [FoodModel.mock]
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.addFoodView(router: router, delegate: AddFoodDelegate(selectedIngredients: $selectedIngredients))
    }
    
}
