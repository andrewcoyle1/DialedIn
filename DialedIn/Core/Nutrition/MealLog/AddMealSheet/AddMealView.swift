//
//  AddMeal.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct AddMealView: View {

    @State var presenter: AddMealPresenter

    let delegate: AddMealDelegate

    var body: some View {
        List {
            timeSection
            notesSection
            itemsSection
        }
        .navigationTitle("Add \(delegate.mealType.rawValue.capitalized)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    private var timeSection: some View {
        Section {
            DatePicker("Time", selection: $presenter.mealTime, displayedComponents: .hourAndMinute)
        }
    }

    private var notesSection: some View {
        Section {
            TextField("Notes (optional)", text: $presenter.notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Notes")
        }
    }

    private var itemsSection: some View {
        Section {
            if presenter.items.isEmpty {
                Text("No items added yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(presenter.items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.displayName)
                            .font(.headline)
                        HStack {
                            Text("\(Int(item.amount)) \(item.unit)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if let calories = item.calories {
                                Text("\(Int(calories)) cal")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: presenter.deleteItems)
            }

            Button {
                presenter.onNutritionLibraryPickerViewPressed()
            } label: {
                Label("Add Item", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Items")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presenter.dismissScreen()
            } label: {
                Image(systemName: "xmark")
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                presenter.saveMeal(selectedDate: delegate.selectedDate, mealType: delegate.mealType, onSave: delegate.onSave)
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.items.isEmpty)
        }
    }
}

extension CoreBuilder {
    func addMealView(router: AnyRouter, delegate: AddMealDelegate) -> some View {
        AddMealView(
            presenter: AddMealPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showAddMealView(delegate: AddMealDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.addMealView(router: router, delegate: delegate)
        }
    }
}

#Preview("Breakfast") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = AddMealDelegate(
        selectedDate: Date(),
        mealType: .breakfast,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Lunch") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = AddMealDelegate(
        selectedDate: Date(),
        mealType: .lunch,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Dinner") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = AddMealDelegate(
        selectedDate: Date(),
        mealType: .dinner,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Snack") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = AddMealDelegate(
        selectedDate: Date(),
        mealType: .snack,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
