//
//  OnboardingCreateProfileViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import PhotosUI

protocol OnboardingCreateProfileInteractor {
    var currentUser: UserModel? { get }
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
}

extension CoreInteractor: OnboardingCreateProfileInteractor { }

@Observable
@MainActor
class OnboardingCreateProfileViewModel {
    private let interactor: OnboardingCreateProfileInteractor
    
    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    var selectedGender: Gender?
    var email: String = ""
    var phoneNumber: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var isSaving: Bool = false
    var navigateNext: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        interactor: OnboardingCreateProfileInteractor
    ) {
        self.interactor = interactor
    }
    
    func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }

    func prefillFromCurrentUser() {
        guard let user = interactor.currentUser else { return }
        firstName = user.firstName ?? firstName
        lastName = user.lastName ?? lastName
        if let existingEmail = user.email { email = existingEmail }
        if let dob = user.dateOfBirth { dateOfBirth = dob }
        if let gender = user.gender { selectedGender = gender }
    }
    
    func saveProfile() async {
        guard canSave else { return }
        isSaving = true
        
        do {
            guard let userId = interactor.currentUser?.userId else {
                interactor.trackEvent(eventName: "profile_save_failed", parameters: ["error": "Missing current user ID"], type: .analytic)
                return
            }

            let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

            let user = UserModel(
                userId: userId,
                email: trimmedEmail.isEmpty ? interactor.currentUser?.email : trimmedEmail,
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

            interactor.trackEvent(eventName: "profile_save_success", parameters: [:], type: .analytic)
            // Proceed to health data step; onboarding completion is finalized on the last step
            navigateNext = true
        } catch {
            interactor.trackEvent(eventName: "profile_save_failed", parameters: ["error": String(describing: error)], type: .analytic)
        }
        isSaving = false
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
