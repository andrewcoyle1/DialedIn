//
//  WorkoutSessionServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol WorkoutSessionServices {
    var remote: RemoteWorkoutSessionService { get }
    var local: LocalWorkoutSessionPersistence { get }
}
