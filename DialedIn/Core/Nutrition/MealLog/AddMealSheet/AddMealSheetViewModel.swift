//
//  AddMealSheetViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

protocol AddMealSheetInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: AddMealSheetInteractor { }

@Observable
@MainActor
class AddMealSheetViewModel {
    private let interactor: AddMealSheetInteractor
    
    var mealTime: Date = Date()
    var notes: String = ""
    var items: [MealItemModel] = []
    var showLibraryPicker: Bool = false
    
    init(interactor: AddMealSheetInteractor) {
        self.interactor = interactor
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    func onAddItemPressed() {
        showLibraryPicker = true
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func saveMeal(onDismiss: () -> Void, selectedDate: Date, mealType: MealType, onSave: @escaping (MealLogModel) -> Void) {
        guard let userId = interactor.currentUser?.userId else { return }
        
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
        onDismiss()
    }
}
