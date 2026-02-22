//
//  CreateExerciseInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

import SwiftUI

@MainActor
protocol CreateExerciseInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: CreateExerciseInteractor { }
