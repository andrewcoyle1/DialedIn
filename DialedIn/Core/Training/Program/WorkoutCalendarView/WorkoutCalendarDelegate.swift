//
//  WorkoutCalendarDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct WorkoutCalendarDelegate {
    let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
    let onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)?
}
