//
//  IngredientDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol IngredientDetailInteractor {
    var currentUser: UserModel? { get }
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws
    func removeFavouritedIngredientTemplate(ingredientId: String) async throws
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws
    func addBookmarkedIngredientTemplate(ingredientId: String) async throws
    func removeBookmarkedIngredientTemplate(ingredientId: String) async throws
    func addFavouritedIngredientTemplate(ingredientId: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: IngredientDetailInteractor { }

@MainActor
protocol IngredientDetailRouter {
    func showDevSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: IngredientDetailRouter { }

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
        isBookmarked = isAuthor || (user?.bookmarkedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false) || (user?.createdIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false)
        isFavourited = user?.favouritedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false
    }
    
    func onBookmarkPressed(ingredientTemplate: IngredientTemplateModel) async {
        interactor.trackEvent(event: Event.bookmarkIngredientStart)
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await interactor.favouriteIngredientTemplate(id: ingredientTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await interactor.removeFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            try await interactor.bookmarkIngredientTemplate(id: ingredientTemplate.id, isBookmarked: newState)
            if newState {
                try await interactor.addBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
            } else {
                try await interactor.removeBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            isBookmarked = newState
            interactor.trackEvent(event: Event.bookmarkIngredientSuccess)
        } catch {
            interactor.trackEvent(event: Event.bookmarkIngredientFail(error: error))
            router.showSimpleAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    func onFavoritePressed(ingredientTemplate: IngredientTemplateModel) async {
        interactor.trackEvent(event: Event.favouriteIngredientSuccess)
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await interactor.bookmarkIngredientTemplate(id: ingredientTemplate.id, isBookmarked: true)
                try await interactor.addBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
                isBookmarked = true
            }
            try await interactor.favouriteIngredientTemplate(id: ingredientTemplate.id, isFavourited: newState)
            if newState {
                try await interactor.addFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            } else {
                try await interactor.removeFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            isFavourited = newState
            interactor.trackEvent(event: Event.favouriteIngredientSuccess)
        } catch {
            interactor.trackEvent(event: Event.favouriteIngredientFail(error: error))
            router.showSimpleAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
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
