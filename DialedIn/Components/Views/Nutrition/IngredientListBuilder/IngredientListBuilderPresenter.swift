import SwiftUI

@Observable
@MainActor
class IngredientListBuilderPresenter {
    
    private let interactor: IngredientListBuilderInteractor
    private let router: IngredientListBuilderRouter
    
    var isLoading: Bool = false
    var searchText: String = ""
    
    var userFoods: [FoodModel] {
        interactor.foods
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var systemFoods: [FoodModel] = []
    
    var filteredFoods: [FoodModel] {
        interactor.foods
            .filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description?.lowercased().contains(searchText.lowercased()) == true
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }

    var currentUser: UserModel? {
        interactor.currentUser
    }

    init(interactor: IngredientListBuilderInteractor, router: IngredientListBuilderRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
        
    func onAddIngredientPressed(delegate: IngredientListBuilderDelegate) {
        interactor.trackEvent(event: Event.onAddIngredientPressed)
        router.showCreateFoodView(delegate: CreateFoodDelegate(mealItems: delegate.mealItems))
    }

    func onIngredientPressed(ingredient: FoodModel, onIngredientPressed: ((FoodModel) -> Void)?) {
        onIngredientPressed?(ingredient)
    }

    // MARK: Analytics Events
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case performIngredientSearchStart
        case performIngredientSearchSuccess(query: String, resultCount: Int)
        case performIngredientSearchFail(error: Error)
        case performIngredientSearchEmptyResults(query: String)
        case searchCleared
        case loadMyIngredientsStart
        case loadMyIngredientsSuccess(count: Int)
        case loadMyIngredientsFail(error: Error)
        case loadTopIngredientsStart
        case loadTopIngredientsSuccess(count: Int)
        case loadTopIngredientsFail(error: Error)
        case incrementIngredientStart
        case incrementIngredientSuccess
        case incrementIngredientFail(error: Error)
        case syncIngredientsFromCurrentUserStart
        case syncIngredientsFromCurrentUserNoUid
        case syncIngredientsFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncIngredientsFromCurrentUserFail(error: Error)
        case onAddIngredientPressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onIngredientPressedFromFavourites
        case onIngredientPressedFromBookmarked
        case onIngredientPressedFromTrending
        case onIngredientPressedFromMyTemplates

        var eventName: String {
            switch self {
            case .onAppear:                                 return "IngredientsView_Appear"
            case .onDisappear:                              return "IngredientsView_Disappear"
            case .performIngredientSearchStart:             return "IngredientsView_Search_Start"
            case .performIngredientSearchSuccess:           return "IngredientsView_Search_Success"
            case .performIngredientSearchFail:              return "IngredientsView_Search_Fail"
            case .performIngredientSearchEmptyResults:      return "IngredientsView_Search_EmptyResults"
            case .searchCleared:                            return "IngredientsView_Search_Cleared"
            case .loadMyIngredientsStart:                   return "IngredientsView_LoadMyIngredients_Start"
            case .loadMyIngredientsSuccess:                 return "IngredientsView_LoadMyIngredients_Success"
            case .loadMyIngredientsFail:                    return "IngredientsView_LoadMyIngredients_Fail"
            case .loadTopIngredientsStart:                  return "IngredientsView_LoadTopIngredients_Start"
            case .loadTopIngredientsSuccess:                return "IngredientsView_LoadTopIngredients_Success"
            case .loadTopIngredientsFail:                   return "IngredientsView_LoadTopIngredients_Fail"
            case .incrementIngredientStart:                 return "IngredientsView_IncrementIngredient_Start"
            case .incrementIngredientSuccess:               return "IngredientsView_IncrementIngredient_Success"
            case .incrementIngredientFail:                  return "IngredientsView_IncrementIngredient_Fail"
            case .syncIngredientsFromCurrentUserStart:      return "IngredientsView_UserSync_Start"
            case .syncIngredientsFromCurrentUserNoUid:      return "IngredientsView_UserSync_NoUID"
            case .syncIngredientsFromCurrentUserSuccess:    return "IngredientsView_UserSync_Success"
            case .syncIngredientsFromCurrentUserFail:       return "IngredientsView_UserSync_Fail"
            case .onAddIngredientPressed:                   return "IngredientsView_AddIngredientPressed"
            case .favouritesSectionViewed:                  return "IngredientsView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:                  return "IngredientsView_Bookmarked_SectionViewed"
            case .trendingSectionViewed:                    return "IngredientsView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:                 return "IngredientsView_MyTemplates_SectionViewed"
            case .emptyStateShown:                          return "IngredientsView_EmptyState_Shown"
            case .onIngredientPressedFromFavourites:        return "IngredientsView_IngredientPressed_Favourites"
            case .onIngredientPressedFromBookmarked:        return "IngredientsView_IngredientPressed_Bookmarked"
            case .onIngredientPressedFromTrending:          return "IngredientsView_IngredientPressed_Trending"
            case .onIngredientPressedFromMyTemplates:       return "IngredientsView_IngredientPressed_MyTemplates"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performIngredientSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performIngredientSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadMyIngredientsSuccess(count: let count):
                return ["count": count]
            case .loadTopIngredientsSuccess(count: let count):
                return ["count": count]
            case .syncIngredientsFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadMyIngredientsFail(error: let error), .loadTopIngredientsFail(error: let error), .performIngredientSearchFail(error: let error), .incrementIngredientFail(error: let error), .syncIngredientsFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadMyIngredientsFail, .loadTopIngredientsFail, .performIngredientSearchFail, .incrementIngredientFail, .syncIngredientsFromCurrentUserFail:
                return .severe
            case .syncIngredientsFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic
            }
        }
    }

}
