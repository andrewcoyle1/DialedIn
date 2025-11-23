//
//  ProfileEditViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import SwiftUI
import PhotosUI

protocol ProfileEditInteractor {
    var currentUser: UserModel? { get }
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
}

extension CoreInteractor: ProfileEditInteractor { }

@MainActor
protocol ProfileEditRouter {
    func showDevSettingsView()
}

extension CoreRouter: ProfileEditRouter { }

@Observable
@MainActor
class ProfileEditViewModel {
    private let interactor: ProfileEditInteractor
    private let router: ProfileEditRouter

    private(set) var isSaving: Bool = false

    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: Date = Date()
    var selectedGender: Gender?
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var showAlert: AnyAppAlert?
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        interactor: ProfileEditInteractor,
        router: ProfileEditRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func presentImagePicker() {
        isImagePickerPresented = true
    }
    
    func trackPhotoSelected() {
        interactor.trackEvent(eventName: "profile_photo_selected", parameters: [:], type: .analytic)
    }
    
    func trackPhotoLoadFailed(error: Error) {
        interactor.trackEvent(eventName: "profile_photo_load_failed", parameters: ["error": String(describing: error)], type: .analytic)
    }
    
    func prefillFromCurrentUser() {
        guard let user = currentUser else { return }
        firstName = user.firstName ?? ""
        lastName = user.lastName ?? ""
        if let dob = user.dateOfBirth {
            dateOfBirth = dob
        }
        selectedGender = user.gender
    }
    
    func saveProfile(onDismiss: () -> Void) async {
        guard canSave else { return }
        isSaving = true
        
        do {
            guard let userId = currentUser?.userId else {
                interactor.trackEvent(eventName: "profile_edit_save_failed", parameters: ["error": "Missing current user ID"], type: .analytic)
                isSaving = false
                return
            }
            
            let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let user = UserModel(
                userId: userId,
                email: currentUser?.email,
                isAnonymous: currentUser?.isAnonymous,
                firstName: trimmedFirst,
                lastName: trimmedLast.isEmpty ? nil : trimmedLast,
                dateOfBirth: dateOfBirth,
                gender: selectedGender
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            try await interactor.saveUser(user: user, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await interactor.saveUser(user: user, image: nsImage)
            #endif
            
            interactor.trackEvent(eventName: "profile_edit_save_success", parameters: [:], type: .analytic)
            onDismiss()
        } catch {
            interactor.trackEvent(eventName: "profile_edit_save_failed", parameters: ["error": String(describing: error)], type: .analytic)
            showAlert = AnyAppAlert(
                title: "Unable to save",
                subtitle: "Please check your internet connection and try again."
            )
        }
        isSaving = false
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
