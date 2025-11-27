//
//  EditProgramInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol EditProgramInteractor {
    func deletePlan(id: String) async throws
    func updatePlan(_ plan: TrainingPlan) async throws
    func getAll() -> [ProgramTemplateModel]
    func get(id: String) -> ProgramTemplateModel?
    func fetchTemplateFromRemote(id: String) async throws -> ProgramTemplateModel
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: EditProgramInteractor { }
