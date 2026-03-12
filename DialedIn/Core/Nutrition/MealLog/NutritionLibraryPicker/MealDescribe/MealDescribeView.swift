import SwiftUI

struct MealDescribeDelegate {
    let onPick: (MealItemModel) -> Void

    var eventParameters: [String: Any]? {
        nil
    }
}

struct MealDescribeView: View {

    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: MealDescribePresenter
    let delegate: MealDescribeDelegate

    var body: some View {
        List {
            Section {
                PromptedTextEditor(
                    text: $presenter.descriptionText,
                    prompt: "Describe your meal"
                )
                .onChange(of: presenter.descriptionText) { _, newValue in
                    if newValue.count > presenter.characterLimit {
                        presenter.descriptionText = String(newValue.prefix(presenter.characterLimit))
                    }
                }
            } header: {
                HStack {
                    Text("Meal Description")
                    Spacer()
                    Text("\(presenter.descriptionText.count)/\(presenter.characterLimit)")
                }
            } footer: {
                Text("Common foods only")
            }

            if let error = presenter.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }

            if !presenter.analysisResults.isEmpty {
                Section("Results") {
                    ForEach(presenter.analysisResults) { item in
                        resultRow(for: item)
                    }
                }
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task { await presenter.onLogFoodsPressed() }
                } label: {
                    if presenter.isAnalysing {
                        ProgressView()
                    } else {
                        Text("Log Foods")
                    }
                }
                .buttonStyle(.glassProminent)
                .disabled(presenter.descriptionText.trimmingCharacters(in: .whitespaces).isEmpty || presenter.isAnalysing)
            }
        }
    }

    private func resultRow(for item: FoodAnalysisItem) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                Text("\(Int(item.amountGrams))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    if let cal = item.calories {
                        macroChip("\(Int(cal)) kcal", color: .orange)
                    }
                    if let protein = item.proteinGrams {
                        macroChip("P \(formatted(protein))g", color: .blue)
                    }
                    if let carbs = item.carbGrams {
                        macroChip("C \(formatted(carbs))g", color: .green)
                    }
                    if let fat = item.fatGrams {
                        macroChip("F \(formatted(fat))g", color: .yellow)
                    }
                }
            }
            Spacer()
            Button("Add") {
                presenter.onAddItem(item, delegate: delegate)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 4)
    }

    private func macroChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2), in: Capsule())
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = MealDescribeDelegate(onPick: { _ in })

    return RouterView { router in
        builder.mealDescribeView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {

    func mealDescribeView(router: AnyRouter, delegate: MealDescribeDelegate) -> some View {
        MealDescribeView(
            presenter: MealDescribePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showMealDescribeView(delegate: MealDescribeDelegate) {
        router.showScreen(.push) { router in
            builder.mealDescribeView(router: router, delegate: delegate)
        }
    }

}
