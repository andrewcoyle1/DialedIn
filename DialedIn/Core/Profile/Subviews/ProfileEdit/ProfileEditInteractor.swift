//
//  ProfileEditInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProfileEditInteractor {
    var currentUser: UserModel? { get }
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
}

extension CoreInteractor: ProfileEditInteractor { }
