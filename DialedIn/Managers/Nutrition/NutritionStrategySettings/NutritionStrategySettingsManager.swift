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
        if settingsSyncEngine.currentDocument == nil {
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
