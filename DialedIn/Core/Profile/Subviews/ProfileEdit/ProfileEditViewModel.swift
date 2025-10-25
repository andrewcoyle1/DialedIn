//
//  ProfileEditViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class ProfileEditViewModel {
    private let userManager: UserManager
    private let logManager: LogManager
    
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
        userManager.currentUser
    }
    
    var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func presentImagePicker() {
        isImagePickerPresented = true
    }
    
    func trackPhotoSelected() {
        logManager.trackEvent(eventName: "profile_photo_selected")
    }
    
    func trackPhotoLoadFailed(error: Error) {
        logManager.trackEvent(eventName: "profile_photo_load_failed", parameters: ["error": String(describing: error)])
    }
    
    func prefillFromCurrentUser() {
        guard let user = userManager.currentUser else { return }
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
            guard let userId = userManager.currentUser?.userId else {
                logManager.trackEvent(eventName: "profile_edit_save_failed", parameters: ["error": "Missing current user ID"])
                isSaving = false
                return
            }
            
            let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let user = UserModel(
                userId: userId,
                email: userManager.currentUser?.email,
                isAnonymous: userManager.currentUser?.isAnonymous,
                firstName: trimmedFirst,
                lastName: trimmedLast.isEmpty ? nil : trimmedLast,
                dateOfBirth: dateOfBirth,
                gender: selectedGender
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            try await userManager.saveUser(user: user, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await userManager.saveUser(user: user, image: nsImage)
            #endif
            
            logManager.trackEvent(eventName: "profile_edit_save_success")
            onDismiss()
        } catch {
            logManager.trackEvent(eventName: "profile_edit_save_failed", parameters: ["error": String(describing: error)])
            showAlert = AnyAppAlert(
                title: "Unable to save",
                subtitle: "Please check your internet connection and try again."
            )
        }
        isSaving = false
    }
}
