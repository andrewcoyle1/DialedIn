//
//  MealDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct MealDetailView: View {
    @State var presenter: MealDetailPresenter

    let delegate: MealDetailDelegate

    var body: some View {
        Text(delegate.meal.id)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.mealDetailView(router: router, delegate: MealDetailDelegate(meal: .mock))
    }
}
