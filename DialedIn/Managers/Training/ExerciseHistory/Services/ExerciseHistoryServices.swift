//
//  ExerciseHistoryServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

protocol ExerciseHistoryServices {
    var remote: RemoteExerciseHistoryService { get }
    var local: LocalExerciseHistoryPersistence { get }
}
