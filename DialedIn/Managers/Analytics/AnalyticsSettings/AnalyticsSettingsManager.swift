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

        // `startListening` does not wait for its listener's first emission, so `currentDocument`
        // is not a reliable answer to "does this user already have a document" immediately after
        // it returns — reading it here raced the listener and could overwrite an existing
        // document (which sections are hidden) with a blank one. `getDocumentAsync` performs a
        // real fetch when nothing is cached yet, so it reflects what is actually stored.
        do {
            _ = try await settingsSyncEngine.getDocumentAsync()
        } catch {
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
