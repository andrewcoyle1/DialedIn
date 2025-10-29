//
//  WorkoutTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol WorkoutTemplateServices {
    var remote: RemoteWorkoutTemplateService { get }
    var local: LocalWorkoutTemplatePersistence { get }
}
