import SwiftUI

struct FoodLibraryDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct FoodLibraryView<
    RecipeList: View,
    IngredientList: View
>: View {
    
    @State var presenter: FoodLibraryPresenter
    let delegate: FoodLibraryDelegate
    
    @ViewBuilder var recipeList: (RecipeListBuilderDelegate) -> RecipeList
    @ViewBuilder var ingredientList: (IngredientListBuilderDelegate) -> IngredientList

    var body: some View {
        Group {
            switch presenter.foodLibraryOption {
            case .recipes:
                recipeList(RecipeListBuilderDelegate())
            case .foods:
                ingredientList(IngredientListBuilderDelegate())
            case .favourites:
                List {
                    Text("Hello, World!")
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Picker(selection: $presenter.foodLibraryOption) {
                    ForEach(FoodLibraryOption.allCases, id: \.self) { option in
                        option.icon.tag(option)
                    }
                } label: {
                    Text("Picker")
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 240)
                Spacer()
            }
            .padding()
        }
        .searchable(text: .constant(""), prompt: "Filter Recipes")
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    
                } label: {
                    Text("Log Foods")
                }
                .buttonStyle(.glassProminent)
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

enum FoodLibraryOption: String, CaseIterable, Hashable, Identifiable {
    var id: String { self.rawValue }
    case recipes
    case foods
    case favourites
    
    var title: String {
        switch self {
        case .recipes: return "Recipes"
        case .foods: return "Foods"
        case .favourites: return "Favourites"
        }
    }
    
    @MainActor
    var icon: some View {
        switch self {
        case .recipes: return Text("Recipes").any()
        case .foods: return Text("Foods").any()
        case .favourites: return Image(systemName: "heart.fill").any()
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = FoodLibraryDelegate()
    
    return RouterView { router in
        builder.foodLibraryView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func foodLibraryView(router: AnyRouter, delegate: FoodLibraryDelegate) -> some View {
        FoodLibraryView(
            presenter: FoodLibraryPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            recipeList: { recipeListDelegate in
                self.recipeListBuilderView(router: router, delegate: recipeListDelegate)
            },
            ingredientList: { ingredientDelegate in
                self.ingredientListBuilderView(router: router, delegate: ingredientDelegate)
            }
        )
    }
    
}

extension CoreRouter {
    
    func showFoodLibraryView(delegate: FoodLibraryDelegate) {
        router.showScreen(.push) { router in
            builder.foodLibraryView(router: router, delegate: delegate)
        }
    }
    
}
