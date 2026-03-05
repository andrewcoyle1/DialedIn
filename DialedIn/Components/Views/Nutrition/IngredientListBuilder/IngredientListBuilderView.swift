import SwiftUI

struct IngredientListBuilderDelegate {
    
    let mealItems: Binding<[MealItemModel]>?
    
    var onIngredientSelectionChanged: ((IngredientTemplateModel) -> Void)?
    /// Optional list of ingredient templates that should display as "selected" in the UI.
    /// If `nil`, no selection state is shown.
    var selectedIngredientTemplates: [IngredientTemplateModel]?
    
    init(
        mealItems: Binding<[MealItemModel]>? = nil,
        onIngredientSelectionChanged: ((IngredientTemplateModel) -> Void)? = nil,
        selectedIngredientTemplates: [IngredientTemplateModel]? = nil
    ) {
        self.mealItems = mealItems
        self.onIngredientSelectionChanged = onIngredientSelectionChanged
        self.selectedIngredientTemplates = selectedIngredientTemplates
    }
}

struct IngredientListBuilderView: View {
    
    @State var presenter: IngredientListBuilderPresenter
    
    let delegate: IngredientListBuilderDelegate
    
    private func isIngredientTemplateSelected(_ ingredientTemplate: IngredientTemplateModel) -> Bool {
        delegate.selectedIngredientTemplates?.contains(ingredientTemplate) ?? false
    }

    var body: some View {
        List {
            if presenter.searchText.isEmpty {
                if !presenter.userIngredientTemplates.isEmpty {
                    userIngredientTemplatesSection
                }
                if !presenter.systemIngredientTemplates.isEmpty {
                    systemIngredientTemplatesSection
                }
            } else {
                filteredIngredientTemplatesSection
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onAddIngredientPressed(delegate: delegate)
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
    
    private var userIngredientTemplatesSection: some View {
        Section {
            ForEach(presenter.userIngredientTemplates) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description,
                    isSelected: isIngredientTemplateSelected(ingredient)
                )
                .anyButton(.highlight) {
                    delegate.onIngredientSelectionChanged?(ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Custom Foods")
        }
    }

    private var systemIngredientTemplatesSection: some View {
        Section {
            ForEach(presenter.systemIngredientTemplates) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description,
                    isSelected: isIngredientTemplateSelected(ingredient)
                )
                .anyButton(.highlight) {
                    delegate.onIngredientSelectionChanged?(ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("System Foods")
        }
    }

    private var filteredIngredientTemplatesSection: some View {
        Section {
            ForEach(presenter.filteredIngredientTemplates) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description,
                    isSelected: isIngredientTemplateSelected(ingredient)
                )
                .anyButton(.highlight) {
                    delegate.onIngredientSelectionChanged?(ingredient)
                }
                .removeListRowFormatting()
            }
        }
    }
}

extension CoreBuilder {
    
    func ingredientListBuilderView(router: AnyRouter, delegate: IngredientListBuilderDelegate) -> some View {
        IngredientListBuilderView(
            presenter: IngredientListBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showIngredientListBuilderView(delegate: IngredientListBuilderDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientListBuilderView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = IngredientListBuilderDelegate()
    
    return RouterView { router in
        builder.ingredientListBuilderView(router: router, delegate: delegate)
    }
}
