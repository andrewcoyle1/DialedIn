//
//  NamePhotoPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class NamePhotoPresenter {
    private let interactor: NamePhotoInteractor
    private let router: NamePhotoRouter

    var firstName: String = ""
    var lastName: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        interactor: NamePhotoInteractor,
        router: NamePhotoRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func prefillFromCurrentUser() {
        guard let user = interactor.currentUser else { return }
        firstName = user.firstName ?? firstName
        lastName = user.lastName ?? lastName
        // Note: We don't prefill the image as it would require fetching from URL
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    func saveAndContinue() {

        guard canContinue else { return }

        router.showLoadingModal()
        interactor.trackEvent(event: Event.namePhotoSaveStart)

        Task {
            defer {
                router.dismissModal()
            }
            
            do {
#if canImport(UIKit)
                if let uiImage = selectedImageData.flatMap({ UIImage(data: $0) }) {
                    try await interactor.updateProfileImageUrl(image: uiImage)
                }
                try await interactor.updateUserName(firstName: firstName, lastName: lastName)
#elseif canImport(AppKit)
                if let nsImage = selectedImageData.flatMap({ NSImage(data: $0) }) {
                    try await interactor.updateProfileImageUrl(image: nsImage)
                }
                try await interactor.updateUserName(firstName: firstName, lastName: lastName)
#endif
                
                interactor.trackEvent(event: Event.namePhotoSaveSuccess)
                router.showGenderView()
            } catch {
                interactor.trackEvent(event: Event.namePhotoSaveFail(error: error))
                router.showSimpleAlert(
                    title: "Unable to save",
                    subtitle: "Please check your internet connection and try again."
                )
            }
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
        case navigate
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
            case .navigate:
                return nil
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
