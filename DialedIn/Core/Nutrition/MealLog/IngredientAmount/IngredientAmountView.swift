//
//  IngredientAmountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

struct IngredientAmountView: View {
    @State var viewModel: IngredientAmountViewModel

    var body: some View {
        Form {
            Section("Amount") {
                HStack {
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                    Text(viewModel.unitLabel)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Estimated Macros") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(viewModel.calories.map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(viewModel.protein.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(viewModel.carbs.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(viewModel.fat.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(viewModel.ingredient.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { viewModel.add() }
                    .disabled((Double(viewModel.amountText) ?? 0) <= 0)
            }
        }
    }
}

#Preview {
    IngredientAmountView(
        viewModel: IngredientAmountViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            ingredient: IngredientTemplateModel.mock,
            onConfirm: {ingredient in
                print(
                    ingredient.displayName
                )
            }
        )
    )
}
