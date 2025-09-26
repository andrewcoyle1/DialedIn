//
//  UserServices.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/15/24.
//

protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistence { get }
}

struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistence

    init(user: UserModel? = nil, delay: Double = 0, showError: Bool = false) {
        self.remote = MockUserService(user: user, delay: delay, showError: showError)
        self.local = MockUserPersistence(user: user)
    }
}

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistence = FileManagerUserPersistence()
}
