//
//  AddMealSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI
import CustomRouting

struct AddMealSheetDelegate {
    let selectedDate: Date
    let mealType: MealType
    let onSave: (MealLogModel) -> Void
}

struct AddMealSheet: View {

    @State var viewModel: AddMealSheetViewModel

    let delegate: AddMealSheetDelegate

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
            DatePicker("Time", selection: $viewModel.mealTime, displayedComponents: .hourAndMinute)
        }
    }

    private var notesSection: some View {
        Section {
            TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Notes")
        }
    }

    private var itemsSection: some View {
        Section {
            if viewModel.items.isEmpty {
                Text("No items added yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.items) { item in
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
                .onDelete(perform: viewModel.deleteItems)
            }

            Button {
                viewModel.onNutritionLibraryPickerViewPressed()
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
            Button("Cancel") {
                viewModel.dismissScreen()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                viewModel.saveMeal(selectedDate: delegate.selectedDate, mealType: delegate.mealType, onSave: delegate.onSave)
            }
            .disabled(viewModel.items.isEmpty)
        }
    }
}

#Preview("Breakfast") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = AddMealSheetDelegate(
        selectedDate: Date(),
        mealType: .breakfast,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealSheet(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Lunch") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = AddMealSheetDelegate(
        selectedDate: Date(),
        mealType: .lunch,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealSheet(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Dinner") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = AddMealSheetDelegate(
        selectedDate: Date(),
        mealType: .dinner,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealSheet(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Snack") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = AddMealSheetDelegate(
        selectedDate: Date(),
        mealType: .snack,
        onSave: { _ in

        }
    )
    RouterView { router in
        builder.addMealSheet(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
