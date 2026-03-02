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
    
    func onDataVisibilityPressed() {
        router.showDataVisibilityView(delegate: DataVisibilityDelegate())
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
        if let dob = user.submittedDateOfBirth {
            dateOfBirth = dob
        }
        selectedGender = user.submittedGender
    }

    func saveProfile() async {
        guard canSave else { return }
        isSaving = true

        do {

            let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)

            var data: [String: any DMCodableSendable] = [
                UserModel.CodingKeys.submittedFirstName.rawValue: trimmedFirst,
                UserModel.CodingKeys.submittedLastName.rawValue: trimmedLast,
                UserModel.CodingKeys.submittedDateOfBirth.rawValue: dateOfBirth
            ]
            if let gender = selectedGender {
                data[UserModel.CodingKeys.submittedFirstName.rawValue] = gender.rawValue
            }
            #if canImport(UIKit)
            if let uiImage = selectedImageData.flatMap({ UIImage(data: $0) }) {
                try await interactor.updateProfileImageUrl(image: uiImage)
            }
            try await interactor.updateUser(data: data)
            #elseif canImport(AppKit)
            if let nsImage = selectedImageData.flatMap({ NSImage(data: $0) }) {
                try await interactor.updateProfileImageUrl(image: nsImage)
            }
            try await interactor.updateUser(data: data)
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
    
    func onEditNamePressed() {
        
    }
    
    func onEditHeightPressed() {
        
    }
    
    func onEditCardioFitnessPressed() {
        
    }
    
    func onEditLiftingExperiencePressed() {
        
    }
    
    func onEditEmailPressed() {
        
    }
    
    func onEditPasswordPressed() {
        
    }

    func onSignOutPressed() {
        interactor.trackEvent(event: Event.signOutStart)

        Task {
            do {
                try await interactor.signOut()
                interactor.trackEvent(event: Event.signOutSuccess)
                dismissEnvironment()
                try await Task.sleep(for: .seconds(1))
                router.switchToOnboardingModule()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }

    private func dismissEnvironment() {
        router.dismissEnvironment()
    }

    func onDeleteAccountPressed() {
        interactor.trackEvent(event: Event.deleteAccountStart)

        router.showAlert(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        self.onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }

    private func onDeleteAccountConfirmed() {
        interactor.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                try await interactor.deleteAccount()
                interactor.trackEvent(event: Event.deleteAccountSuccess)
                dismissEnvironment()
                try await Task.sleep(for: .seconds(1))
                router.switchToOnboardingModule()

            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }

}

extension AccountPresenter {
    
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case onAppear(delegate: AccountDelegate)
        case onDisappear(delegate: AccountDelegate)

        var eventName: String {
            switch self {
            case .signOutStart:                 return "Settings_SignOut_Start"
            case .signOutSuccess:               return "Settings_SignOut_Success"
            case .signOutFail:                  return "Settings_SignOut_Fail"
            case .deleteAccountStart:           return "Settings_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    return "Settings_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         return "Settings_DeleteAccount_Success"
            case .deleteAccountFail:            return "Settings_DeleteAccount_Fail"
            case .onAppear:                 return "AccountView_Appear"
            case .onDisappear:              return "AccountView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
