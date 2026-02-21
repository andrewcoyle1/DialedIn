//
//  IngredientDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class IngredientDetailPresenter {
    private let interactor: IngredientDetailInteractor
    private let router: IngredientDetailRouter

    var isBookmarked: Bool = false
    var isFavourited: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: IngredientDetailInteractor,
        router: IngredientDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadInitialState(ingredientTemplate: IngredientTemplateModel) async {
        let user = interactor.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == ingredientTemplate.authorId
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case favouriteIngredientStart
        case favouriteIngredientSuccess
        case favouriteIngredientFail(error: Error)
        case bookmarkIngredientStart
        case bookmarkIngredientSuccess
        case bookmarkIngredientFail(error: Error)

        var eventName: String {
            switch self {
            case .favouriteIngredientStart:    return "IngredientDetailView_Favourite_Start"
            case .favouriteIngredientSuccess:  return "IngredientDetailView_Favourite_Success"
            case .favouriteIngredientFail:     return "IngredientDetailView_Favourite_Fail"
            case .bookmarkIngredientStart:    return "IngredientDetailView_Bookmark_Start"
            case .bookmarkIngredientSuccess:  return "IngredientDetailView_Bookmark_Success"
            case .bookmarkIngredientFail:     return "IngredientDetailView_Bookmark_Fail"
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
