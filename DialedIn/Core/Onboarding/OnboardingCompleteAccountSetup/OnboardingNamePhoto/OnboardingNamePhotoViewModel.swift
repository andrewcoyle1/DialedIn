//
//  OnboardingNamePhotoViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import PhotosUI

protocol OnboardingNamePhotoInteractor {
    var currentUser: UserModel? { get }
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
}

extension CoreInteractor: OnboardingNamePhotoInteractor { }

@Observable
@MainActor
class OnboardingNamePhotoViewModel {
    private let interactor: OnboardingNamePhotoInteractor
    
    var firstName: String = ""
    var lastName: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var isSaving: Bool = false
    var showAlert: AnyAppAlert?
    var navigateToGender: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        interactor: OnboardingNamePhotoInteractor
    ) {
        self.interactor = interactor
    }
    
    func prefillFromCurrentUser() {
        guard let user = interactor.currentUser else { return }
        firstName = user.firstName ?? firstName
        lastName = user.lastName ?? lastName
        // Note: We don't prefill the image as it would require fetching from URL
    }
    
    func saveAndContinue() async {
        guard canContinue else { return }
        isSaving = true
        
        do {
            guard let userId = interactor.currentUser?.userId else {
                interactor.trackEvent(eventName: "name_photo_save_failed", parameters: ["error": "Missing current user ID"], type: .analytic)
                isSaving = false
                return
            }
            
            let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let user = UserModel(
                userId: userId,
                email: interactor.currentUser?.email,
                isAnonymous: interactor.currentUser?.isAnonymous,
                firstName: trimmedFirst,
                lastName: trimmedLast.isEmpty ? nil : trimmedLast
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            try await interactor.saveUser(user: user, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await interactor.saveUser(user: user, image: nsImage)
            #endif
            
            interactor.trackEvent(eventName: "name_photo_save_success", parameters: [:], type: .analytic)
            isSaving = false
            navigateToGender = true
        } catch {
            interactor.trackEvent(eventName: "name_photo_save_failed", parameters: ["error": String(describing: error)], type: .analytic)
            showAlert = AnyAppAlert(
                title: "Unable to save",
                subtitle: "Please check your internet connection and try again."
            )
            isSaving = false
        }
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil) {
        interactor.trackEvent(eventName: eventName, parameters: parameters, type: .analytic)
    }
    
    func handlePhotoSelection() async {
        guard let photoItem = selectedPhotoItem else { return }
        
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self) {
                selectedImageData = data
                trackEvent(eventName: "profile_photo_selected")
            } else {
                trackEvent(eventName: "profile_photo_load_empty")
            }
        } catch {
            trackEvent(eventName: "profile_photo_load_failed", parameters: ["error": String(describing: error)])
        }
    }
}
