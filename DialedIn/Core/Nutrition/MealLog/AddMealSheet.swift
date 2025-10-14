//
//  AddMealSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct AddMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserManager.self) private var userManager
    
    let selectedDate: Date
    let mealType: MealType
    let onSave: (MealLogModel) -> Void
    
    @State private var mealTime: Date = Date()
    @State private var notes: String = ""
    @State private var items: [MealItemModel] = []
    @State private var showLibraryPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Time", selection: $mealTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
                
                Section {
                    if items.isEmpty {
                        Text("No items added yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(items) { item in
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
                        .onDelete(perform: deleteItems)
                    }
                    
                    Button {
                        onAddItemPressed()
                    } label: {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Items")
                }
            }
            .navigationTitle("Add \(mealType.rawValue.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLibraryPicker) {
                    NutritionLibraryPickerView { newItem in
                        items.append(newItem)
                        showLibraryPicker = false
                    }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMeal()
                    }
                    .disabled(items.isEmpty)
                }
            }
        }
    }
    
    private func onAddItemPressed() {
        showLibraryPicker = true
    }
    
    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    private func saveMeal() {
        guard let userId = userManager.currentUser?.userId else { return }
        
        // Combine selected date with selected time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: mealTime)
        
        var finalComponents = DateComponents()
        finalComponents.year = dateComponents.year
        finalComponents.month = dateComponents.month
        finalComponents.day = dateComponents.day
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute
        
        let finalDate = calendar.date(from: finalComponents) ?? selectedDate
        
        // Calculate totals
        let totalCalories = items.compactMap { $0.calories }.reduce(0, +)
        let totalProtein = items.compactMap { $0.proteinGrams }.reduce(0, +)
        let totalCarbs = items.compactMap { $0.carbGrams }.reduce(0, +)
        let totalFat = items.compactMap { $0.fatGrams }.reduce(0, +)
        
        let meal = MealLogModel(
            mealId: UUID().uuidString,
            authorId: userId,
            dayKey: selectedDate.dayKey,
            date: finalDate,
            mealType: mealType,
            items: items,
            notes: notes.isEmpty ? nil : notes,
            totalCalories: totalCalories,
            totalProteinGrams: totalProtein,
            totalCarbGrams: totalCarbs,
            totalFatGrams: totalFat
        )
        
        onSave(meal)
        dismiss()
    }
}

#Preview("Breakfast") {
    AddMealSheet(
        selectedDate: Date(),
        mealType: .breakfast,
        onSave: { _ in
        }
    )
    .previewEnvironment()
}

#Preview("Lunch") {
    AddMealSheet(
        selectedDate: Date(),
        mealType: .lunch,
        onSave: { _ in
        }
    )
    .previewEnvironment()
}

#Preview("Dinner") {
    AddMealSheet(
        selectedDate: Date(),
        mealType: .dinner,
        onSave: { _ in
        }
    )
    .previewEnvironment()
}

#Preview("Snack") {
    AddMealSheet(
        selectedDate: Date(),
        mealType: .snack,
        onSave: { _ in
        }
    )
    .previewEnvironment()
}
