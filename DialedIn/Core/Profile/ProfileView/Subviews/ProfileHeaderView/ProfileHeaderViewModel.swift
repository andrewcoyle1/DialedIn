//
//  ProfileHeaderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileHeaderInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: ProfileHeaderInteractor { }

@Observable
@MainActor
class ProfileHeaderViewModel {
    private let interactor: ProfileHeaderInteractor

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: ProfileHeaderInteractor
    ) {
        self.interactor = interactor
    }
}
