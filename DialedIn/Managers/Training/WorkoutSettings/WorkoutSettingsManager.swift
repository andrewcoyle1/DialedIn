import Foundation

@Observable
@MainActor
class WorkoutSettingsManager {

    private let workoutSettingsSyncEngine: DocumentSyncEngine<WorkoutSettings>
    private var userId: String?

    var workoutSettings: WorkoutSettings {
        workoutSettingsSyncEngine.currentDocument ?? WorkoutSettings(authorId: userId ?? "")
    }

    init(workoutSettingsSyncEngine: DocumentSyncEngine<WorkoutSettings>) {
        self.workoutSettingsSyncEngine = workoutSettingsSyncEngine
    }

    // MARK: - Public Methods

    func signIn(userId: String) async throws {
        self.userId = userId
        try await workoutSettingsSyncEngine.startListening(documentId: "workout_settings")
        if workoutSettingsSyncEngine.currentDocument == nil {
            try await workoutSettingsSyncEngine.saveDocument(WorkoutSettings(authorId: userId))
        }
    }

    func signOut() {
        workoutSettingsSyncEngine.stopListening()
    }

    func saveSettings(_ settings: WorkoutSettings) async throws {
        try await workoutSettingsSyncEngine.saveDocument(settings)
    }
}

extension CoreInteractor {
    // MARK: WorkoutSettingsManager

    var workoutSettings: WorkoutSettings {
        workoutSettingsManager.workoutSettings
    }

    func saveWorkoutSettings(_ settings: WorkoutSettings) async throws {
        try await workoutSettingsManager.saveSettings(settings)
    }
}
