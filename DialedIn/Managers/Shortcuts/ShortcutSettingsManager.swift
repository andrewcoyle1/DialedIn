//
//  ShortcutSettingsManager.swift
//  DialedIn
//

import Foundation

@Observable
@MainActor
class ShortcutSettingsManager {

    private let settingsSyncEngine: DocumentSyncEngine<ShortcutSettings>
    private var userId: String?

    var shortcutSettings: ShortcutSettings {
        settingsSyncEngine.currentDocument ?? ShortcutSettings(authorId: userId ?? "")
    }

    init(settingsSyncEngine: DocumentSyncEngine<ShortcutSettings>) {
        self.settingsSyncEngine = settingsSyncEngine
    }

    // MARK: - Public Methods

    func signIn(userId: String) async throws {
        self.userId = userId
        try await settingsSyncEngine.startListening(documentId: "shortcut_settings")
        if settingsSyncEngine.currentDocument == nil {
            try await settingsSyncEngine.saveDocument(ShortcutSettings(authorId: userId))
        }
    }

    func signOut() {
        settingsSyncEngine.stopListening()
    }

    func saveSettings(_ settings: ShortcutSettings) async throws {
        try await settingsSyncEngine.saveDocument(settings)
    }
}

extension CoreInteractor {
    // MARK: ShortcutSettingsManager

    var shortcutSettings: ShortcutSettings {
        shortcutSettingsManager.shortcutSettings
    }

    func saveShortcutSettings(_ settings: ShortcutSettings) async throws {
        try await shortcutSettingsManager.saveSettings(settings)
    }
}
