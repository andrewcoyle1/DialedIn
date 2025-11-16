//
//  MealDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

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
    builder.mealDetailView(delegate: MealDetailViewDelegate(meal: .mock))
}
