//
//  ExerciseTrackerCardDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/12/2025.
//

import SwiftUI

struct ExerciseTrackerCardDelegate {
    var exercise: WorkoutExerciseModel
    var exerciseIndex: Int
    var isCurrentExercise: Bool
    var isExpanded: Binding<Bool>
    var restBeforeSetIdToSec: [String: Int]
    let onNotesChanged: (String, String) -> Void
    let onAddSet: (String) -> Void
    let onDeleteSet: (String, String) -> Void
    let onUpdateSet: (WorkoutSetModel, String) -> Void
    let onRestBeforeChange: (String, Int?) -> Void
    var onRequestRestPicker: (String, Int?) -> Void = { _, _ in }
}
