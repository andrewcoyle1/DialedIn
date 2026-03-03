//
//  NameWorkoutInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol NameWorkoutInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func saveWorkoutTemplate(workoutTemplate: WorkoutTemplateModel, image: PlatformImage?) async throws
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: NameWorkoutInteractor { }
