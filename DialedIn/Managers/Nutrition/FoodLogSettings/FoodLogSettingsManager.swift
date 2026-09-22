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

        // `startListening` does not wait for its listener's first emission, so `currentDocument`
        // is not a reliable answer to "does this user already have a document" immediately after
        // it returns — reading it here raced the listener and could overwrite an existing
        // document (favourites included) with a blank one. `getDocumentAsync` performs a real
        // fetch when nothing is cached yet, so it reflects what is actually stored.
        do {
            _ = try await foodLogSettingsSyncEngine.getDocumentAsync()
        } catch {
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

    // MARK: Favourites

    func isFavouriteFood(id: String) -> Bool {
        foodLogSettings.favouriteFoodIds.contains(id)
    }

    func isFavouriteRecipe(id: String) -> Bool {
        foodLogSettings.favouriteRecipeIds.contains(id)
    }

    func setFavouriteFood(id: String, isFavourite: Bool) async throws {
        var settings = foodLogSettings
        settings.favouriteFoodIds = Self.updating(settings.favouriteFoodIds, id: id, isMember: isFavourite)
        try await foodLogSettingsManager.saveSettings(settings)
    }

    func setFavouriteRecipe(id: String, isFavourite: Bool) async throws {
        var settings = foodLogSettings
        settings.favouriteRecipeIds = Self.updating(settings.favouriteRecipeIds, id: id, isMember: isFavourite)
        try await foodLogSettingsManager.saveSettings(settings)
    }

    /// An array rather than a Set, because the settings document is Codable and a Set would change
    /// how it serialises. Duplicates are still avoided.
    private static func updating(_ ids: [String], id: String, isMember: Bool) -> [String] {
        guard isMember else { return ids.filter { $0 != id } }
        return ids.contains(id) ? ids : ids + [id]
    }
}
