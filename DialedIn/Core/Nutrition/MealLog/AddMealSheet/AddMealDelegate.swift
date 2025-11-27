//
//  AddMealDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

struct AddMealDelegate {
    let selectedDate: Date
    let mealType: MealType
    let onSave: (MealLogModel) -> Void
}
