//
//  ProgramManagementInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProgramManagementInteractor: GlobalInteractor {
    var trainingPrograms: [TrainingProgram] { get }
    func setActiveTrainingProgram(programId: String) async throws
    func deleteTrainingProgram(programId: String) async throws
}

extension CoreInteractor: ProgramManagementInteractor { }
