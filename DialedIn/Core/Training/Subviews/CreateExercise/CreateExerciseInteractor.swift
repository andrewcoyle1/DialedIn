//
//  CreateExerciseInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

import SwiftUI

protocol CreateExerciseInteractor {
    var currentUser: UserModel? { get }
    func createExerciseTemplate(exercise: ExerciseTemplateModel, image: PlatformImage?) async throws
    func addCreatedExerciseTemplate(exerciseId: String) async throws
    func addBookmarkedExerciseTemplate(exerciseId: String) async throws
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws
    func generateImage(input: String) async throws -> UIImage
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: CreateExerciseInteractor { }
