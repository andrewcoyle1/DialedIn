//
//  ProfileHeaderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileHeaderViewModel {
    private let userManager: UserManager

    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
    }
}
