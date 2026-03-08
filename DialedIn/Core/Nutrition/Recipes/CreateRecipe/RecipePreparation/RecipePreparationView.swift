import SwiftUI

struct RecipePreparationDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct RecipePreparationView: View {
    
    @State var presenter: RecipePreparationPresenter
    let delegate: RecipePreparationDelegate
    
    var body: some View {
        List {
            Text("Hello, World!")
        }
        .navigationTitle("Create Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = RecipePreparationDelegate()
    
    return RouterView { router in
        builder.recipePreparationView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func recipePreparationView(router: AnyRouter, delegate: RecipePreparationDelegate) -> some View {
        RecipePreparationView(
            presenter: RecipePreparationPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showRecipePreparationView(delegate: RecipePreparationDelegate) {
        router.showScreen(.push) { router in
            builder.recipePreparationView(router: router, delegate: delegate)
        }
    }
    
}
