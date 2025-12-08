//
//  AddIngredientModalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct AddIngredientModalView: View {

    @State var presenter: AddIngredientModalPresenter

    var delegate: AddIngredientModalDelegate

    private var filteredIngredients: [IngredientTemplateModel] {
        let query = presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return presenter.ingredients }
        return presenter.ingredients.filter { ingredient in
            var fields: [String] = [
                ingredient.name
            ]
            if let description = ingredient.description { fields.append(description) }
            return fields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    var body: some View {
        Group {
            if presenter.isLoading {
                VStack {
                    ProgressView()
                    Text("Loading ingredients...")
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = presenter.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text("Error Loading Ingredients")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task {
                            await presenter.loadIngredients()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                listSection
            }
        }
        .searchable(text: $presenter.searchText)
        .navigationTitle("Add Ingredients")
        .navigationSubtitle("Select one or more ingredients to add")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            await presenter.loadIngredients()
        }
        .onChange(of: presenter.searchText) {
            Task {
                await presenter.searchIngredients()
            }
        }
    }

    private var listSection: some View {
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
    }
}

extension CoreBuilder {
    func addIngredientModalView(router: AnyRouter, delegate: AddIngredientModalDelegate) -> some View {
        AddIngredientModalView(
            presenter: AddIngredientModalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showAddIngredientView(delegate: AddIngredientModalDelegate) {
        router.showScreen(.sheet) { router in
            builder.addIngredientModalView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    @Previewable @State var selectedIngredients: [IngredientTemplateModel] = [IngredientTemplateModel.mock]
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.addIngredientModalView(router: router, delegate: AddIngredientModalDelegate(selectedIngredients: $selectedIngredients))
    }
    .previewEnvironment()
}
