//
//  AddMealPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class AddMealPresenter {
    private let interactor: AddMealInteractor
    private let router: AddMealRouter

    var mealTime: Date = Date()
    var notes: String = ""
    var items: [MealItemModel] = []
    var showLibraryPicker: Bool = false
    var showAllNutrients: Bool = false
    var nutritionScope: NutritionScope = .plate
    
    init(
        interactor: AddMealInteractor,
        router: AddMealRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
        
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func onShowPickerPressed() {
        let delegate = NutritionLibraryPickerDelegate(
            items: Binding(get: {
                self.items
            }, set: { newValues in
                self.items = newValues
            }),
            onPick: { newItem in
            self.items.append(newItem)
        })
        router.showNutritionLibraryPickerView(delegate: delegate)
    }

    func saveMeal(selectedDate: Date, onSave: @escaping (MealLogModel) -> Void) {
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
            items: items,
            notes: notes.isEmpty ? nil : notes,
            totalCalories: totalCalories,
            totalProteinGrams: totalProtein,
            totalCarbGrams: totalCarbs,
            totalFatGrams: totalFat
        )
        
        onSave(meal)
        dismissScreen()
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}

enum NutritionScope: String, DataSyncModelProtocol, CaseIterable {
    var id: String { self.rawValue }
    case plate
    case day
}
