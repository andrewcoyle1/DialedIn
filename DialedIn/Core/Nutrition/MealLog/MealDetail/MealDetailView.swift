//
//  MealDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct MealDetailDelegate {
    let meal: MealLogModel
}

struct MealDetailView: View {
    @State var presenter: MealDetailPresenter

    let delegate: MealDetailDelegate

    var body: some View {
        Text(delegate.meal.id)
    }
}

extension CoreBuilder {
    func mealDetailView(router: AnyRouter, delegate: MealDetailDelegate) -> some View {
        MealDetailView(
            presenter: MealDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showMealDetailView(delegate: MealDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.mealDetailView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.mealDetailView(router: router, delegate: MealDetailDelegate(meal: .mock))
    }
}
