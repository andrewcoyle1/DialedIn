//
//  IngredientsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct IngredientsView<IngredientList: View>: View {
    
    @State var presenter: IngredientsPresenter

    @ViewBuilder var ingredientListViewBuilder: (IngredientListBuilderDelegate) -> IngredientList

    var body: some View {
        let delegate = IngredientListBuilderDelegate(onIngredientPressed: presenter.onIngredientPressed)
        ingredientListViewBuilder(delegate)
    }
}

extension CoreBuilder {
    func ingredientsView(router: AnyRouter) -> some View {
        IngredientsView(
            presenter: IngredientsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            ingredientListViewBuilder: { delegate in
                self.ingredientListBuilderView(router: router, delegate: delegate)
            }
        )
    }
}

extension CoreRouter {
    func showIngredientsView() {
        router.showScreen(.push) { router in
            builder.ingredientsView(router: router)
        }
    }
}

#Preview("Ingredients View") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    List {
        RouterView { router in
            builder.ingredientsView(
                router: router
            )
        }
    }
    .previewEnvironment()
}
