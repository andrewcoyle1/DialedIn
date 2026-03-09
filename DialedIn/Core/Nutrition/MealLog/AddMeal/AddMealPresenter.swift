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
    
    var mealLog: MealLogModel {
        didSet {
            guard !mealLog.items.isEmpty else { return }
            saveDraftMeal()
        }
    }
    
    var showAllNutrients: Bool = false
    var nutritionScope: NutritionScope = .plate
    
    init(
        interactor: AddMealInteractor,
        router: AddMealRouter,
        delegate: AddMealDelegate
    ) {
        self.interactor = interactor
        self.router = router
        self.mealLog = delegate.mealLog
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
        
    func deleteItems(at offsets: IndexSet) {
        mealLog.items.remove(atOffsets: offsets)
    }
    
    func onShowPickerPressed() {
        let delegate = NutritionLibraryPickerDelegate(
            items: Binding(get: {
                self.mealLog.items
            }, set: { newValues in
                self.mealLog.items = newValues
            }),
            onPick: { newItem in
                self.mealLog.items.append(newItem)
        })
        router.showNutritionLibraryPickerView(delegate: delegate)
    }
    
    // MARK: - Persistence
    
    func saveDraftMeal() {
        do {
            try interactor.updateDraftMeal(mealLog)
        } catch {
            router.showSimpleAlert(title: "Unable to Save Progress", subtitle: "We were unable to save your workout. Please try again.")
        }
    }

    func saveMeal() {
        Task {
            do {
                try await interactor.saveMeal(mealLog)
                self.dismissScreen()
            } catch {
                
            }
        }
    }

    func dismissScreen() {
        if self.mealLog.items.isEmpty {
            try? self.interactor.deleteDraftMeal()
        }
        router.dismissScreen()
    }
}

enum NutritionScope: String, DataSyncModelProtocol, CaseIterable {
    var id: String { self.rawValue }
    case plate
    case day
}

enum AddMealError: LocalizedError { case noCurrentUser }
