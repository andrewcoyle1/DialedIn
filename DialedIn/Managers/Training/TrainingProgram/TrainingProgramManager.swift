//
//  TrainingProgramManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

@Observable
@MainActor
class TrainingProgramManager {

    private let trainingProgramSyncEngine: CollectionSyncEngine<TrainingProgram>
    private let logManager: LogManager

    var trainingPrograms: [TrainingProgram] {
        trainingProgramSyncEngine.currentCollection
    }

    init(trainingProgramSyncEngine: CollectionSyncEngine<TrainingProgram>, logManager: LogManager) {
        self.trainingProgramSyncEngine = trainingProgramSyncEngine
        self.logManager = logManager
    }

    func signIn(userId: String) async {
        logManager.trackEvent(event: Event.signIn(userId: userId))
        await trainingProgramSyncEngine.startListening()

        let loadedCount = trainingProgramSyncEngine.currentCollection.count
        if loadedCount == 0 {
            logManager.trackEvent(event: Event.bulkLoadEmpty(userId: userId))
        } else {
            logManager.trackEvent(event: Event.bulkLoadSuccess(userId: userId, count: loadedCount))
        }
    }

    func signOut() {
        trainingProgramSyncEngine.stopListening()
    }

    func saveTrainingProgram(trainingProgram: TrainingProgram) async throws {
        do {
            try await trainingProgramSyncEngine.saveDocument(trainingProgram)
        } catch {
            logManager.trackEvent(event: Event.saveFail(programId: trainingProgram.id, error: error))
            throw error
        }
    }

    // MARK: DELETE

    func deleteTrainingProgram(programId: String) async throws {
        do {
            try await trainingProgramSyncEngine.deleteDocument(id: programId)
        } catch {
            logManager.trackEvent(event: Event.deleteFail(programId: programId, error: error))
            throw error
        }
    }
}

extension TrainingProgramManager {
    enum Event: LoggableEvent {
        case signIn(userId: String)
        case bulkLoadSuccess(userId: String, count: Int)
        case bulkLoadEmpty(userId: String)
        case saveFail(programId: String, error: Error)
        case deleteFail(programId: String, error: Error)

        var eventName: String {
            switch self {
            case .signIn:           return "training_program_signIn"
            case .bulkLoadSuccess:  return "training_program_bulkLoad_success"
            case .bulkLoadEmpty:    return "training_program_bulkLoad_empty"
            case .saveFail:         return "training_program_save_fail"
            case .deleteFail:       return "training_program_delete_fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signIn(let userId):
                return ["user_id": userId]
            case .bulkLoadSuccess(let userId, let count):
                return ["user_id": userId, "count": count]
            case .bulkLoadEmpty(let userId):
                return ["user_id": userId]
            case .saveFail(let programId, let error):
                return [
                    "program_id": programId,
                    "error_description": "\(error)",
                    "error_localized": error.localizedDescription
                ]
            case .deleteFail(let programId, let error):
                return [
                    "program_id": programId,
                    "error_description": "\(error)",
                    "error_localized": error.localizedDescription
                ]
            }
        }

        var type: LogType {
            switch self {
            case .saveFail, .deleteFail:    return .severe
            case .bulkLoadEmpty:            return .severe
            default:                        return .analytic
            }
        }
    }
}

extension CoreInteractor {
    // MARK: TrainingProgramManager

    var activeTrainingProgram: TrainingProgram? {
        guard let activeTrainingProgramId = currentUser?.submittedActiveTrainingProgramId else { return nil }
        return trainingPrograms.first { program in
            program.id == activeTrainingProgramId
        }
    }

    var trainingPrograms: [TrainingProgram] {
        trainingProgramManager.trainingPrograms
    }

    func saveTrainingProgram(trainingProgram: TrainingProgram) async throws {
        try await trainingProgramManager.saveTrainingProgram(trainingProgram: trainingProgram)
    }

    func deleteTrainingProgram(programId: String) async throws {
        try await trainingProgramManager.deleteTrainingProgram(programId: programId)
    }

}
