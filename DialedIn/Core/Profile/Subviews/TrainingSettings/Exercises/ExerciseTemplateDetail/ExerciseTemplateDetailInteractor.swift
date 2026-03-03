//
//  ExerciseModelDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol ExerciseModelDetailInteractor {
    var currentUser: UserModel? { get }
    func getPreference(templateId: String) -> ExerciseUnitPreference
}

extension CoreInteractor: ExerciseModelDetailInteractor { }
