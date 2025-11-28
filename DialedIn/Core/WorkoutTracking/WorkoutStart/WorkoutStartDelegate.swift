//
//  WorkoutStartDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct WorkoutStartDelegate {

    let template: WorkoutTemplateModel
    let scheduledWorkout: ScheduledWorkout?

    init(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout? = nil) {
        self.template = template
        self.scheduledWorkout = scheduledWorkout
    }
}
