import Foundation

@Observable
@MainActor
class WorkoutSettingsManager {

    private let userDefaults: UserDefaults
    private let userManager: UserManager

    private var settingsCache: WorkoutSettings?

    init(userDefaults: UserDefaults = .standard, userManager: UserManager) {
        self.userDefaults = userDefaults
        self.userManager = userManager
    }

    // MARK: - Public Methods

    func getSettings() -> WorkoutSettings {
        if let cached = settingsCache {
            return cached
        }

        if let userId = userManager.currentUser?.userId,
           let data = userDefaults.data(forKey: settingsKey(userId: userId)),
           let settings = try? JSONDecoder().decode(WorkoutSettings.self, from: data) {
            settingsCache = settings
            return settings
        }

        let defaults = WorkoutSettings()
        settingsCache = defaults
        return defaults
    }

    func saveSettings(_ settings: WorkoutSettings) {
        guard let userId = userManager.currentUser?.userId,
              let data = try? JSONEncoder().encode(settings) else {
            return
        }
        userDefaults.set(data, forKey: settingsKey(userId: userId))
        settingsCache = settings
    }

    func clearCache() {
        settingsCache = nil
    }

    // MARK: - Private

    private func settingsKey(userId: String) -> String {
        "workout_settings_\(userId)"
    }
}

extension CoreInteractor {
    // MARK: WorkoutSettingsManager

    var workoutSettings: WorkoutSettings {
        workoutSettingsManager.getSettings()
    }

    func saveWorkoutSettings(_ settings: WorkoutSettings) {
        workoutSettingsManager.saveSettings(settings)
    }
}
