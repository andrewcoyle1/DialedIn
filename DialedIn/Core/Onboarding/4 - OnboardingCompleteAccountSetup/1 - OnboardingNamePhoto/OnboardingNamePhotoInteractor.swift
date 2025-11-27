//
//  OnboardingNamePhotoInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingNamePhotoInteractor {
    var currentUser: UserModel? { get }
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingNamePhotoInteractor { }
