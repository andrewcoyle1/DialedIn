//
//  FoodDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class FoodDetailPresenter {
    private let interactor: FoodDetailInteractor
    private let router: FoodDetailRouter

    var isBookmarked: Bool = false
    var isFavourited: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: FoodDetailInteractor,
        router: FoodDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case favouriteIngredientStart
        case favouriteIngredientSuccess
        case favouriteIngredientFail(error: Error)
        case bookmarkIngredientStart
        case bookmarkIngredientSuccess
        case bookmarkIngredientFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                     return "FoodDetailView_Appear"
            case .onDisappear:                  return "FoodDetailView_Disappear"
            case .favouriteIngredientStart:     return "FoodDetailView_Favourite_Start"
            case .favouriteIngredientSuccess:   return "FoodDetailView_Favourite_Success"
            case .favouriteIngredientFail:      return "FoodDetailView_Favourite_Fail"
            case .bookmarkIngredientStart:      return "FoodDetailView_Bookmark_Start"
            case .bookmarkIngredientSuccess:    return "FoodDetailView_Bookmark_Success"
            case .bookmarkIngredientFail:       return "FoodDetailView_Bookmark_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .favouriteIngredientFail(error: let error), .bookmarkIngredientFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .favouriteIngredientFail, .bookmarkIngredientFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
