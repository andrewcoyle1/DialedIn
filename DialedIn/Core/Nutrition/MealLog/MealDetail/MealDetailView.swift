//
//  MealDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import CustomRouting

struct MealDetailViewDelegate {
    let meal: MealLogModel
}

struct MealDetailView: View {
    @State var viewModel: MealDetailViewModel

    let delegate: MealDetailViewDelegate

    var body: some View {
        Text(delegate.meal.id)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.mealDetailView(router: router, delegate: MealDetailViewDelegate(meal: .mock))
    }
}
