//
//  AnalyticsSettingsManager.swift
//  DialedIn
//

import Foundation

@Observable
@MainActor
class AnalyticsSettingsManager {

    private let settingsSyncEngine: DocumentSyncEngine<AnalyticsSettings>
    private var userId: String?

    var analyticsSettings: AnalyticsSettings {
        settingsSyncEngine.currentDocument ?? AnalyticsSettings(authorId: userId ?? "")
    }

    init(settingsSyncEngine: DocumentSyncEngine<AnalyticsSettings>) {
        self.settingsSyncEngine = settingsSyncEngine
    }

    // MARK: - Public Methods

    func signIn(userId: String) async throws {
        self.userId = userId
        try await settingsSyncEngine.startListening(documentId: "analytics_settings")
        if settingsSyncEngine.currentDocument == nil {
            try await settingsSyncEngine.saveDocument(AnalyticsSettings(authorId: userId))
        }
    }

    func signOut() {
        settingsSyncEngine.stopListening()
    }

    func saveSettings(_ settings: AnalyticsSettings) async throws {
        try await settingsSyncEngine.saveDocument(settings)
    }
}

extension CoreInteractor {
    // MARK: AnalyticsSettingsManager

    var analyticsSettings: AnalyticsSettings {
        analyticsSettingsManager.analyticsSettings
    }

    func saveAnalyticsSettings(_ settings: AnalyticsSettings) async throws {
        try await analyticsSettingsManager.saveSettings(settings)
    }
}
