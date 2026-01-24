import SwiftUI

@Observable
@MainActor
class GymProfilesPresenter {
    
    private let interactor: GymProfilesInteractor
    private let router: GymProfilesRouter
    
    private(set) var gymProfiles: [GymProfileModel] = []
    
    var numGyms: Int {
        gymProfiles.count
    }
    
    var favouriteGymProfileId: String? {
        interactor.currentUser?.favouriteGymProfileId
    }
    
    init(interactor: GymProfilesInteractor, router: GymProfilesRouter) {
        self.interactor = interactor
        self.router = router
        self.loadLocalGymProfiles()
    }
    
    func loadLocalGymProfiles() {
        interactor.trackEvent(event: Event.loadLocalGymProfileStart)
        do {
            gymProfiles = try interactor.readAllLocalGymProfiles()
            interactor.trackEvent(event: Event.loadLocalGymProfileSuccess)
        } catch {
            router.showAlert(error: error)
            interactor.trackEvent(event: Event.loadLocalGymProfileFail(error: error))
        }
    }
    
    func loadRemoteGymProfiles() async {
        interactor.trackEvent(event: Event.loadRemoteGymProfileStart)
        do {
            guard let userId = interactor.userId else { return }
            gymProfiles = try await interactor.readAllRemoteGymProfilesForAuthor(userId: userId)
            interactor.trackEvent(event: Event.loadRemoteGymProfileSuccess)
        } catch {
            interactor.trackEvent(event: Event.loadRemoteGymProfileFail(error: error))
        }
    }
    
    func onAddGymProfilePressed() {
        guard let userId = interactor.userId else { return }
        router.showGymProfileView(gymProfile: GymProfileModel(authorId: userId))
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onGymProfilePressed(gymProfile: GymProfileModel) {
        router.showGymProfileView(gymProfile: gymProfile)
    }
        
    func deleteGymProfile(profile: GymProfileModel) {
        Task {
            interactor.trackEvent(event: Event.deleteProfileStart)
            do {
                try await interactor.deleteGymProfile(profile: profile)
                gymProfiles.removeAll { $0.id == profile.id }
                interactor.trackEvent(event: Event.deleteProfileSuccess)
            } catch {
                interactor.trackEvent(event: Event.deleteProfileFail(error: error))
            }
        }
    }
    
    func favouriteGymProfile(profile: GymProfileModel) {
        Task {
            interactor.trackEvent(event: Event.favouriteGymProfileStart)

            do {
                try await interactor.updateFavouriteGymProfileId(profileId: profile.id)
                interactor.trackEvent(event: Event.favouriteGymProfileSuccess)

            } catch {
                interactor.trackEvent(event: Event.favouriteGymProfileFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case deleteProfileStart
        case deleteProfileSuccess
        case deleteProfileFail(error: Error)
        case loadLocalGymProfileStart
        case loadLocalGymProfileSuccess
        case loadLocalGymProfileFail(error: Error)
        case loadRemoteGymProfileStart
        case loadRemoteGymProfileSuccess
        case loadRemoteGymProfileFail(error: Error)
        case favouriteGymProfileStart
        case favouriteGymProfileSuccess
        case favouriteGymProfileFail(error: Error)

        var eventName: String {
            switch self {
            case .deleteProfileStart:           return "GymProfilesView_DeleteProfile_Start"
            case .deleteProfileSuccess:         return "GymProfilesView_DeleteProfile_Success"
            case .deleteProfileFail:            return "GymProfilesView_DeleteProfile_Fail"
            case .loadLocalGymProfileStart:     return "GymProfilesView_LoadLocalGymProfiles_Start"
            case .loadLocalGymProfileSuccess:   return "GymProfilesView_LoadLocalGymProfiles_Success"
            case .loadLocalGymProfileFail:      return "GymProfilesView_LoadLocalGymProfiles_Fail"
            case .loadRemoteGymProfileStart:    return "GymProfilesView_LoadRemoteGymProfiles_Start"
            case .loadRemoteGymProfileSuccess:  return "GymProfilesView_LoadRemoteGymProfiles_Success"
            case .loadRemoteGymProfileFail:     return "GymProfilesView_LoadRemoteGymProfiles_Fail"
            case .favouriteGymProfileStart:     return "GymProfilesView_FavouriteGymProfile_Start"
            case .favouriteGymProfileSuccess:   return "GymProfilesView_FavouriteGymProfile_Success"
            case .favouriteGymProfileFail:      return "GymProfilesView_FavouriteGymProfile_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .deleteProfileFail(error: let error),
                    .loadLocalGymProfileFail(error: let error),
                    .loadRemoteGymProfileFail(error: let error),
                    .favouriteGymProfileFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .deleteProfileFail, .loadLocalGymProfileFail, .loadRemoteGymProfileFail, .favouriteGymProfileFail:
                return.severe
            default:
                return .analytic
                
            }
        }
    }
}
