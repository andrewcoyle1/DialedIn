import SwiftUI
import PhotosUI

@Observable
@MainActor
class AccountPresenter {
    
    private let interactor: AccountInteractor
    private let router: AccountRouter

    private(set) var isSaving: Bool = false

    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: Date = Date()
    var selectedGender: Gender?
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }

    var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(interactor: AccountInteractor, router: AccountRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: AccountDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: AccountDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
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

    func saveProfile() async {
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
            router.dismissScreen()
        } catch {
            interactor.trackEvent(eventName: "profile_edit_save_failed", parameters: ["error": String(describing: error)], type: .analytic)
            router.showSimpleAlert(
                title: "Unable to save",
                subtitle: "Please check your internet connection and try again."
            )
        }
        isSaving = false
    }

}

extension AccountPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: AccountDelegate)
        case onDisappear(delegate: AccountDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "AccountView_Appear"
            case .onDisappear:              return "AccountView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}
