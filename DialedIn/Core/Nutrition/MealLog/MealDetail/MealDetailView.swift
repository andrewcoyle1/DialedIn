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

/// A read-only summary of a meal that has already been logged.
///
/// Deliberately not `AddMealView`: that screen is the in-progress plate editor, and every mutation
/// to its `mealLog` autosaves to the *draft* meal. Editing a historical entry through it would
/// overwrite whatever plate the user is currently assembling.
struct MealDetailView: View {

    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: MealDetailPresenter

    let delegate: MealDetailDelegate

    var body: some View {
        NavigationStack {
            List {
                summarySection
                itemsSection
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear {
                presenter.onViewAppear(delegate: delegate)
            }
        }
    }

    private var summarySection: some View {
        Section {
            HStack {
                ForEach(presenter.macroSummary(for: delegate.meal)) { macro in
                    VStack(spacing: 2) {
                        Text(macro.value)
                            .font(.headline)
                        Text(macro.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(delegate.meal.date.formatted(date: .abbreviated, time: .shortened))
        }
    }

    @ViewBuilder
    private var itemsSection: some View {
        if delegate.meal.items.isEmpty {
            Section {
                Text("This meal has no items.")
                    .foregroundStyle(.secondary)
            }
        } else {
            Section {
                ForEach(delegate.meal.items) { item in
                    MealItemRowView(
                        mealLogModel: delegate.meal,
                        item: item,
                        showTimestamp: false,
                        onEditPressed: { _ in }
                    )
                }
            } header: {
                Text("Items")
            }
            .listRowSeparator(.hidden)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(role: .destructive) {
                presenter.onDeletePressed(meal: delegate.meal)
            } label: {
                Image(systemName: "trash")
            }
            .accessibilityLabel("Delete meal")
        }
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
