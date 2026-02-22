//
//  NameWorkoutInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol NameWorkoutInteractor {
    var currentUser: UserModel? { get }
    func updateWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: NameWorkoutInteractor { }
