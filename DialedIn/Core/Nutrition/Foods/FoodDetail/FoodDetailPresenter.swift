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
        
    func onViewAppear(delegate: FoodDetailDelegate) {
        isFavourited = interactor.isFavouriteFood(id: delegate.food.id)
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    /// Favourites are stored per user on the food log settings, which is what the library's
    /// Favourites tab reads.
    func onFavouritePressed(delegate: FoodDetailDelegate) {
        let newValue = !isFavourited
        isFavourited = newValue
        interactor.trackEvent(event: Event.favouriteIngredientStart)
        Task {
            do {
                try await interactor.setFavouriteFood(id: delegate.food.id, isFavourite: newValue)
                interactor.trackEvent(event: Event.favouriteIngredientSuccess)
            } catch {
                isFavourited = !newValue
                interactor.trackEvent(event: Event.favouriteIngredientFail(error: error))
            }
        }
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

        var eventName: String {
            switch self {
            case .onAppear:                     return "FoodDetailView_Appear"
            case .onDisappear:                  return "FoodDetailView_Disappear"
            case .favouriteIngredientStart:     return "FoodDetailView_Favourite_Start"
            case .favouriteIngredientSuccess:   return "FoodDetailView_Favourite_Success"
            case .favouriteIngredientFail:      return "FoodDetailView_Favourite_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .favouriteIngredientFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .favouriteIngredientFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
