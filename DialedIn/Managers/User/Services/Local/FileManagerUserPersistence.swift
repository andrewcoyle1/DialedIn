//
//  FileManagerUserPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//
import SwiftUI

@MainActor
struct FileManagerUserPersistence: LocalUserPersistence {
    private let userDocumentKey = "current_user"
    
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
    
    func clearCurrentUser() {
        try? FileManager.default.removeItem(at: FileManager.getDocumentURL(for: userDocumentKey))
    }
}
