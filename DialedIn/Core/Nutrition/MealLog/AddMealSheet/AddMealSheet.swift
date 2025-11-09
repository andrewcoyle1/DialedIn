//
//  AddMealSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct AddMealSheet: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: AddMealSheetViewModel

    @Binding var path: [TabBarPathOption]

    var body: some View {
        NavigationStack {
            List {
                timeSection
                notesSection
                itemsSection
            }
            .navigationTitle("Add \(viewModel.mealType.rawValue.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showLibraryPicker) {
                NutritionLibraryPickerView(viewModel: NutritionLibraryPickerViewModel(interactor: CoreInteractor(container: container), onPick: { newItem in
                    viewModel.items.append(newItem)
                    viewModel.showLibraryPicker = false
                }), path: $path)
            }
            .toolbar {
                toolbarContent
            }
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
                viewModel.onAddItemPressed()
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
                dismiss()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                viewModel.saveMeal(onDismiss: { dismiss() })
            }
            .disabled(viewModel.items.isEmpty)
        }
    }
}

#Preview("Breakfast") {
    @Previewable @State var path: [TabBarPathOption] = []
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .breakfast,
            onSave: { _ in
            }
        ),
        path: $path
    )
    .previewEnvironment()
}

#Preview("Lunch") {
    @Previewable @State var path: [TabBarPathOption] = []
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .lunch,
            onSave: { _ in
            }
        ),
        path: $path
    )
    .previewEnvironment()
}

#Preview("Dinner") {
    @Previewable @State var path: [TabBarPathOption] = []
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .dinner,
            onSave: { _ in
            }
        ),
        path: $path
    )
    .previewEnvironment()
}

#Preview("Snack") {
    @Previewable @State var path: [TabBarPathOption] = []
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .snack,
            onSave: { _ in
            }
        ),
        path: $path
    )
    .previewEnvironment()
}
