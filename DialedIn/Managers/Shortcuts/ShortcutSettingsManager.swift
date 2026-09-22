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

        // `startListening` does not wait for its listener's first emission, so `currentDocument`
        // is not a reliable answer to "does this user already have a document" immediately after
        // it returns — reading it here raced the listener and could overwrite an existing
        // document (a curated shortcut order included) with a blank one. `getDocumentAsync`
        // performs a real fetch when nothing is cached yet, so it reflects what is actually
        // stored.
        do {
            _ = try await settingsSyncEngine.getDocumentAsync()
        } catch {
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
