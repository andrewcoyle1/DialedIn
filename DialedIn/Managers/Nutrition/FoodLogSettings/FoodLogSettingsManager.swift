import Foundation

@Observable
@MainActor
class FoodLogSettingsManager {

    private let foodLogSettingsSyncEngine: DocumentSyncEngine<FoodLogSettings>
    private var userId: String?

    var foodLogSettings: FoodLogSettings {
        foodLogSettingsSyncEngine.currentDocument ?? FoodLogSettings(authorId: userId ?? "")
    }

    init(foodLogSettingsSyncEngine: DocumentSyncEngine<FoodLogSettings>) {
        self.foodLogSettingsSyncEngine = foodLogSettingsSyncEngine
    }

    // MARK: - Public Methods

    func signIn(userId: String) async throws {
        self.userId = userId
        try await foodLogSettingsSyncEngine.startListening(documentId: "food_log_settings")
        if foodLogSettingsSyncEngine.currentDocument == nil {
            try await foodLogSettingsSyncEngine.saveDocument(FoodLogSettings(authorId: userId))
        }
    }

    func signOut() {
        foodLogSettingsSyncEngine.stopListening()
    }

    func saveSettings(_ settings: FoodLogSettings) async throws {
        try await foodLogSettingsSyncEngine.saveDocument(settings)
    }
}

extension CoreInteractor {
    // MARK: FoodLogSettingsManager

    var foodLogSettings: FoodLogSettings {
        foodLogSettingsManager.foodLogSettings
    }

    func saveFoodLogSettings(_ settings: FoodLogSettings) async throws {
        try await foodLogSettingsManager.saveSettings(settings)
    }
}
