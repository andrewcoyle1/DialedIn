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
    func trackEvent(event: LoggableEvent)
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
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(interactor: OnboardingNamePhotoInteractor) {
        self.interactor = interactor
    }
    
    func prefillFromCurrentUser() {
        guard let user = interactor.currentUser else { return }
        firstName = user.firstName ?? firstName
        lastName = user.lastName ?? lastName
        // Note: We don't prefill the image as it would require fetching from URL
    }
    
    func saveAndContinue(path: Binding<[OnboardingPathOption]>) async {
        guard canContinue else { return }
        isSaving = true
        interactor.trackEvent(event: Event.namePhotoSaveStart)
        defer {
            isSaving = false
        }
        
        do {
            guard let userId = interactor.currentUser?.userId else {
                interactor.trackEvent(event: Event.noUserId)
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
            
            interactor.trackEvent(event: Event.namePhotoSaveSuccess)
            interactor.trackEvent(event: Event.navigate(destination: .gender))
            path.wrappedValue.append(.gender)
        } catch {
            interactor.trackEvent(event: Event.namePhotoSaveFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to save",
                subtitle: "Please check your internet connection and try again."
            )
        }
    }
    
    func handlePhotoSelection() async {
        guard let photoItem = selectedPhotoItem else { 
            return 
        }
        interactor.trackEvent(event: Event.profilePhotoSelected)
        interactor.trackEvent(event: Event.profilePhotoLoadStart)
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self) {
                selectedImageData = data
                interactor.trackEvent(event: Event.profilePhotoLoadSuccess)
            } else {
                interactor.trackEvent(event: Event.profilePhotoLoadEmpty)
            }
        } catch {
            interactor.trackEvent(event: Event.profilePhotoLoadFail(error: error))
        }
    }

    enum Event: LoggableEvent {

        case profilePhotoSelected
        case profilePhotoNotSelected
        case profilePhotoLoadStart
        case profilePhotoLoadSuccess
        case profilePhotoLoadEmpty
        case profilePhotoLoadFail(error: Error)
        case namePhotoSaveStart
        case namePhotoSaveSuccess
        case namePhotoSaveFail(error: Error)
        case navigate(destination: OnboardingPathOption)
        case noUserId

        var eventName: String {
            switch self {
            case .profilePhotoSelected:     return "NamePhoto_PhotoSelected"
            case .profilePhotoNotSelected:  return "NamePhoto_PhotoNotSelected"
            case .profilePhotoLoadStart:    return "NamePhoto_PhotoLoad_Start"
            case .profilePhotoLoadSuccess:  return "NamePhoto_PhotoLoad_Success"
            case .profilePhotoLoadEmpty:    return "NamePhoto_PhotoLoad_Empty"
            case .profilePhotoLoadFail:     return "NamePhoto_PhotoLoad_Fail"
            case .namePhotoSaveStart:       return "NamePhoto_Save_Start"
            case .namePhotoSaveSuccess:     return "NamePhoto_Save_Success"
            case .namePhotoSaveFail:        return "NamePhoto_Save_Fail"
            case .navigate:                 return "NamePhoto_Navigate"
            case .noUserId:                 return "NamePhoto_NoUserID"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
            case .profilePhotoLoadFail(error: let error), .namePhotoSaveFail(error: let error):
                return error.eventParameters
            case .noUserId:
                return [
                    "error": "Missing current user ID"
                ]
            default: 
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .profilePhotoSelected, 
                 .profilePhotoNotSelected, 
                 .profilePhotoLoadStart, 
                 .profilePhotoLoadSuccess, 
                 .profilePhotoLoadEmpty, 
                 .profilePhotoLoadFail, 
                 .navigate: 
                return .info
            case .noUserId, .namePhotoSaveFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
