import SwiftUI

struct RecipeListBuilderDelegate {
    var onRecipeSelectionChanged: ((RecipeTemplateModel) -> Void)?
    /// Optional list of recipe templates that should display as "selected" in the UI.
    /// If `nil`, no selection state is shown.
    var selectedRecipeTemplates: [RecipeTemplateModel]?
}

struct RecipeListBuilderView: View {
    
    @State var presenter: RecipeListBuilderPresenter
    
    let delegate: RecipeListBuilderDelegate
    
    private func isRecipeTemplateSelected(_ recipeTemplate: RecipeTemplateModel) -> Bool {
        delegate.selectedRecipeTemplates?.contains(recipeTemplate) ?? false
    }

    var body: some View {
        List {
            if presenter.searchText.isEmpty {
                if !presenter.userRecipeTemplates.isEmpty {
                    userRecipeTemplatesSection
                }
                if !presenter.systemRecipeTemplates.isEmpty {
                    systemRecipeTemplatesSection
                }
            } else {
                filteredRecipeTemplatesSection
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
                    presenter.onAddRecipePressed()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
    
    // MARK: UI Components
    private var userRecipeTemplatesSection: some View {
        Section {
            ForEach(presenter.userRecipeTemplates) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description,
                    isSelected: isRecipeTemplateSelected(recipe)
                )
                .anyButton(.highlight) {
                    delegate.onRecipeSelectionChanged?(recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Custom Recipes")
        }
    }

    private var systemRecipeTemplatesSection: some View {
        Section {
            ForEach(presenter.systemRecipeTemplates) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description,
                    isSelected: isRecipeTemplateSelected(recipe)
                )
                .anyButton(.highlight) {
                    delegate.onRecipeSelectionChanged?(recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("System Recipes")
        }
    }

    private var filteredRecipeTemplatesSection: some View {
        Section {
            ForEach(presenter.filteredRecipeTemplates) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description,
                    isSelected: isRecipeTemplateSelected(recipe)
                )
                .anyButton(.highlight) {
                    delegate.onRecipeSelectionChanged?(recipe)
                }
                .removeListRowFormatting()
            }
        }
    }
}

extension CoreBuilder {
    
    func recipeListBuilderView(router: AnyRouter, delegate: RecipeListBuilderDelegate) -> some View {
        RecipeListBuilderView(
            presenter: RecipeListBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showRecipeListBuilderView(delegate: RecipeListBuilderDelegate) {
        router.showScreen(.push) { router in
            builder.recipeListBuilderView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = RecipeListBuilderDelegate()
    
    return RouterView { router in
        builder.recipeListBuilderView(router: router, delegate: delegate)
    }
}
