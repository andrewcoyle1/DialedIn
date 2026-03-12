//
//  MealHourHeaderPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/03/2026.
//

import SwiftUI

@Observable
@MainActor
class MealHourHeaderPresenter {
    private let interactor: MealHourHeaderInteractor
    private let router: MealHourHeaderRouter
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: MealHourHeaderInteractor,
        router: MealHourHeaderRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onAddMealPressed(selectedTime: Date = Date()) {
        guard let userId = currentUser?.userId else { return }
        if let meal = interactor.draftMeal {
            router.showAlert(
                title: "Unable to add new meal",
                subtitle: "You already have an draft meal.",
                buttons: {
                    AnyView(
                        VStack {
                            Button("Continue editing") {
                                self.router.showAddMealView(
                                    delegate: AddMealDelegate(mealLog: meal)
                                )
                            }
                            Button("Delete drafted meal", role: .destructive) {
                                try? self.interactor.deleteDraftMeal()
                                self.router.showAddMealView(
                                    delegate: AddMealDelegate(
                                        mealLog: MealLogModel(
                                            authorId: userId,
                                            dayKey: selectedTime.dayKey,
                                            date: selectedTime,
                                            items: []
                                        )
                                    )
                                )
                            }
                            Button("Cancel", role: .cancel) { }
                        }
                    )
                }
            )
        } else {
            self.router.showAddMealView(
                delegate: AddMealDelegate(
                    mealLog: MealLogModel(
                        authorId: userId,
                        dayKey: selectedTime.dayKey,
                        date: selectedTime,
                        items: []
                    )
                )
            )
        }
    }

}
