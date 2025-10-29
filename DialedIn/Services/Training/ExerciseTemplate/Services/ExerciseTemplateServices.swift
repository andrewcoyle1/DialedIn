//
//  ExerciseTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol ExerciseTemplateServices {
    var remote: RemoteExerciseTemplateService { get }
    var local: LocalExerciseTemplatePersistence { get }
}
