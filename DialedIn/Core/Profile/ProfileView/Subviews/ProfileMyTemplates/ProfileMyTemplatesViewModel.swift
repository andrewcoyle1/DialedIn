//
//  ProfileMyTemplatesViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileMyTemplatesInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: ProfileMyTemplatesInteractor { }

@Observable
@MainActor
class ProfileMyTemplatesViewModel {
    private let interactor: ProfileMyTemplatesInteractor
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: ProfileMyTemplatesInteractor
    ) {
        self.interactor = interactor
    }
}
