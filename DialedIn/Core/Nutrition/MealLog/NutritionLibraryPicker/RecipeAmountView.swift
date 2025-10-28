//
//  RecipeAmountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

struct RecipeAmountView: View {
    @State var viewModel: RecipeAmountViewModel

    var body: some View {
        Form {
            Section("Servings") {
                TextField("Servings", text: $viewModel.servingsText)
                    .keyboardType(.decimalPad)
            }
            Section("Estimated Macros (per serving)") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(viewModel.baseCalories.map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(viewModel.baseProtein.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(viewModel.baseCarbs.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(viewModel.baseFat.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(viewModel.recipe.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { viewModel.add() }
                    .disabled(viewModel.servings <= 0)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeAmountView(
            viewModel: RecipeAmountViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                recipe: RecipeTemplateModel.mock,
                onConfirm: { meal in
                    print(meal.id)
                }
            )
        )
    }
}
