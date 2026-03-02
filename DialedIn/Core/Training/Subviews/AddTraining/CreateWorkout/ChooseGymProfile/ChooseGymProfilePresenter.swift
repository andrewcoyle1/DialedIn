import SwiftUI

@Observable
@MainActor
class ChooseGymProfilePresenter {
    
    private let interactor: ChooseGymProfileInteractor
    private let router: ChooseGymProfileRouter
    
    var favouriteGymProfile: GymProfileModel? {
        interactor.favouriteGymProfile
    }
    
    var gymProfiles: [GymProfileModel] {
        interactor.gymProfiles
    }
    
    var numGyms: Int {
        gymProfiles.count
    }
    
    var favouriteGymProfileId: String? {
        interactor.currentUser?.submittedFavouriteGymProfileId
    }

    init(interactor: ChooseGymProfileInteractor, router: ChooseGymProfileRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func onGymProfilePressed(name: String, profile: GymProfileModel) {
        router.showDefineWorkoutWrapperView(delegate: DefineWorkoutWrapperDelegate(name: name, gymProfile: profile))
    }
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
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
            case .onAppear:                     return "GymProfilesView_Appear"
            case .onDisappear:                  return "GymProfilesView_Disappear"
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
