//
//  MealDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct MealDetailView: View {
    @State var viewModel: MealDetailViewModel

    var body: some View {
        Text(viewModel.meal.id)
    }
}

#Preview {
    MealDetailView(
        viewModel: MealDetailViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            meal: .mock
        )
    )
}
