import SwiftUI

@Observable
@MainActor
class FoodItemSearchPresenter {

    private let interactor: FoodItemSearchInteractor
    private let router: FoodItemSearchRouter

    private(set) var historyFoods: [FoodModel] = []
    private(set) var openFoodFactsFoods: [FoodModel] = []
    private(set) var isSearching: Bool = false

    var searchText: String = ""

    private var searchTask: Task<Void, Never>?

    init(interactor: FoodItemSearchInteractor, router: FoodItemSearchRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: FoodItemSearchDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        historyFoods = interactor.recentFoods
    }

    func onViewDisappear(delegate: FoodItemSearchDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
        searchTask?.cancel()
    }

    func onSearchTextChanged(_ text: String) {
        searchTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            openFoodFactsFoods = []
            return
        }
        guard interactor.foodLogSettings.showOpenFoodFactsFoods else {
            openFoodFactsFoods = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            guard !Task.isCancelled else { return }
            isSearching = true
            defer { isSearching = false }
            do {
                openFoodFactsFoods = try await interactor.searchOpenFoodFacts(query: trimmed)
                if !interactor.foodLogSettings.showBrandedFoods {
                    openFoodFactsFoods = openFoodFactsFoods.filter { $0.brandName == nil }
                }
            } catch {
                interactor.trackEvent(event: Event.searchError(error: error))
                openFoodFactsFoods = []
            }
        }
    }
}

extension FoodItemSearchPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: FoodItemSearchDelegate)
        case onDisappear(delegate: FoodItemSearchDelegate)
        case searchError(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:    return "FoodItemSearchView_Appear"
            case .onDisappear: return "FoodItemSearchView_Disappear"
            case .searchError: return "FoodItemSearchView_SearchError"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(let delegate), .onDisappear(let delegate):
                return delegate.eventParameters
            case .searchError(error: let error):
                return error.eventParameters
            }
        }

        var type: LogType {
            switch self {
            case .searchError: return .severe
            default: return .analytic
            }
        }
    }
}

enum FocusField: Hashable {
    case searchBar
}
