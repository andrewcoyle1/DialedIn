//
//  WorkoutStartDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct WorkoutStartDelegate {

    let template: WorkoutTemplateModel
    var scheduledWorkout: ScheduledWorkout?
    var programId: String?
    var dayPlanId: String?
    var onStartWorkoutPressed: (() -> Void)?
    var onCancelPressed: (() -> Void)?
}
