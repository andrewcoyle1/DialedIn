//
//  WorkoutStartDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct WorkoutStartDelegate {

    let template: WorkoutTemplateModel
    var scheduledWorkout: ScheduledWorkout?
    var onStartWorkout: ((WorkoutSessionModel) -> Void)?
}
