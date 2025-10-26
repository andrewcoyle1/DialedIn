//
//  AddMealSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct AddMealSheet: View {
    @State var viewModel: AddMealSheetViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Time", selection: $viewModel.mealTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
                
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
            .navigationTitle("Add \(viewModel.mealType.rawValue.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showLibraryPicker) {
                NutritionLibraryPickerView(viewModel: NutritionLibraryPickerViewModel(interactor: CoreInteractor(container: container), onPick: { newItem in
                    viewModel.items.append(newItem)
                    viewModel.showLibraryPicker = false
                }))
            }
            .toolbar {
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
    }
}

#Preview("Breakfast") {
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .breakfast,
            onSave: { _ in
            }
        )
    )
    .previewEnvironment()
}

#Preview("Lunch") {
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .lunch,
            onSave: { _ in
            }
        )
    )
    .previewEnvironment()
}

#Preview("Dinner") {
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .dinner,
            onSave: { _ in
            }
        )
    )
    .previewEnvironment()
}

#Preview("Snack") {
    AddMealSheet(
        viewModel: AddMealSheetViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            selectedDate: Date(),
            mealType: .snack,
            onSave: { _ in
            }
        )
    )
    .previewEnvironment()
}
