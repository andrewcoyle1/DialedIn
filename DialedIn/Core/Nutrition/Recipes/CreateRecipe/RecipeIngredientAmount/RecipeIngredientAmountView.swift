import SwiftUI

struct RecipeIngredientAmountDelegate {
    let food: FoodModel
    let onConfirm: (RecipeIngredientModel) -> Void
}

struct RecipeIngredientAmountView: View {
    @State var presenter: RecipeIngredientAmountPresenter
    let delegate: RecipeIngredientAmountDelegate

    var body: some View {
        Form {
            Section("Amount") {
                HStack {
                    TextField("Amount", text: $presenter.amountText)
                        .keyboardType(.decimalPad)
                    Text(presenter.unitLabel(food: delegate.food))
                        .foregroundStyle(.secondary)
                }
            }
            Section("Estimated Macros") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(presenter.calories(food: delegate.food).map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(presenter.protein(food: delegate.food).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(presenter.carbs(food: delegate.food).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(presenter.fat(food: delegate.food).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(delegate.food.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    presenter.confirm(delegate: delegate)
                }
                .disabled((Double(presenter.amountText) ?? 0) <= 0)
            }
        }
    }
}

extension CoreBuilder {
    func recipeIngredientAmountView(router: AnyRouter, delegate: RecipeIngredientAmountDelegate) -> some View {
        RecipeIngredientAmountView(
            presenter: RecipeIngredientAmountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showRecipeIngredientAmountView(delegate: RecipeIngredientAmountDelegate) {
        router.showScreen(.push) { router in
            builder.recipeIngredientAmountView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.recipeIngredientAmountView(
            router: router,
            delegate: RecipeIngredientAmountDelegate(
                food: FoodModel.mock,
                onConfirm: { _ in }
            )
        )
    }
}
