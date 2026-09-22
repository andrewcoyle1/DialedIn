//
//  NutritionStrategySettingsManager.swift
//  DialedIn
//

import Foundation

@Observable
@MainActor
class NutritionStrategySettingsManager {

    private let settingsSyncEngine: DocumentSyncEngine<NutritionStrategySettings>
    private var userId: String?

    var nutritionStrategySettings: NutritionStrategySettings {
        settingsSyncEngine.currentDocument ?? NutritionStrategySettings(authorId: userId ?? "")
    }

    init(settingsSyncEngine: DocumentSyncEngine<NutritionStrategySettings>) {
        self.settingsSyncEngine = settingsSyncEngine
    }

    // MARK: - Public Methods

    func signIn(userId: String) async throws {
        self.userId = userId
        try await settingsSyncEngine.startListening(documentId: "nutrition_strategy_settings")

        // `startListening` does not wait for its listener's first emission, so `currentDocument`
        // is not a reliable answer to "does this user already have a document" immediately after
        // it returns — reading it here raced the listener and could overwrite an existing
        // document with a blank one. `getDocumentAsync` performs a real fetch when nothing is
        // cached yet, so it reflects what is actually stored.
        do {
            _ = try await settingsSyncEngine.getDocumentAsync()
        } catch {
            try await settingsSyncEngine.saveDocument(NutritionStrategySettings(authorId: userId))
        }
    }

    func signOut() {
        settingsSyncEngine.stopListening()
    }

    func saveSettings(_ settings: NutritionStrategySettings) async throws {
        try await settingsSyncEngine.saveDocument(settings)
    }
}

extension CoreInteractor {
    // MARK: NutritionStrategySettingsManager

    var nutritionStrategySettings: NutritionStrategySettings {
        nutritionStrategySettingsManager.nutritionStrategySettings
    }

    func saveNutritionStrategySettings(_ settings: NutritionStrategySettings) async throws {
        try await nutritionStrategySettingsManager.saveSettings(settings)
    }
}
