//
//  MockUserServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistence

    init(user: UserModel? = nil, delay: Double = 0, showError: Bool = false) {
        self.remote = MockUserService(user: user, delay: delay, showError: showError)
        self.local = MockUserPersistence(user: user)
    }
}
