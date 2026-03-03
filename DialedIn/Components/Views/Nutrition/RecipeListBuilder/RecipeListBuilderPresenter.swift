import SwiftUI

@Observable
@MainActor
class RecipeListBuilderPresenter {
    
    private let interactor: RecipeListBuilderInteractor
    private let router: RecipeListBuilderRouter
    
    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    
    var userRecipeTemplates: [RecipeTemplateModel] {
        interactor.userRecipeTemplates
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var systemRecipeTemplates: [RecipeTemplateModel] = []
    
    var filteredRecipeTemplates: [RecipeTemplateModel] {
        interactor.userRecipeTemplates
            .filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description?.lowercased().contains(searchText.lowercased()) == true ||
                $0.ingredients
                    .contains { value in
                        value.name.lowercased().contains(searchText.lowercased())
                    } == true
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(interactor: RecipeListBuilderInteractor, router: RecipeListBuilderRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func onAddRecipePressed() {
        router.showCreateRecipeView()
    }

    func onRecipePressed(recipe: RecipeTemplateModel, onRecipePressed: ((RecipeTemplateModel) -> Void)? = nil) {
        onRecipePressed?(recipe)
    }

    enum Event: LoggableEvent {
        case onAppear
        case onDisappear

        var eventName: String {
            switch self {
            case .onAppear:     return "RecipesView_Appear"
            case .onDisappear:  return "RecipesView_Disappear"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
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
