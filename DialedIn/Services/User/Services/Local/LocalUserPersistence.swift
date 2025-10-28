//
//  LocalUserPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//

protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
    func clearCurrentUser()
}
