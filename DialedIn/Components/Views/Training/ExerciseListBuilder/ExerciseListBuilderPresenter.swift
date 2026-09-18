import SwiftUI

@Observable
@MainActor
class ExerciseListBuilderPresenter {
    
    private let interactor: ExerciseListBuilderInteractor
    private let router: ExerciseListBuilderRouter

    private(set) var isLoading: Bool = false
    private(set) var searchExerciseTask: Task<Void, Never>?
    
    /// The filter bar's state. Every list below runs through it, so a filter set with no search
    /// text narrows the browse sections too — not only the search results.
    var filters = ExerciseFilters()

    var userExercises: [ExerciseModel] {
        matching(interactor.userExercises)
    }

    var systemExercises: [ExerciseModel] {
        matching(interactor.systemExercises)
    }

    var filteredExercises: [ExerciseModel] {
        matching(filterBySearchText(interactor.allExercises))
    }

    var searchText: String = ""
    var selectedWorkoutTemplate: WorkoutTemplateModel?
    var selectedExerciseModel: ExerciseModel?

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedSearchText: String {
        trimmedSearchText.lowercased()
    }

    var currentUser: UserModel? {
        interactor.currentUser
    }

    init(interactor: ExerciseListBuilderInteractor, router: ExerciseListBuilderRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    // MARK: - Filtering

    var gymProfiles: [GymProfileModel] {
        interactor.gymProfiles.filter { $0.deletedAt == nil }
    }

    /// The chosen gym's *active* equipment. A profile lists every equipment type with an on/off
    /// flag, so the inactive ones are exactly the things that gym does not have.
    private var availableEquipment: Set<EquipmentRef> {
        guard
            let gymProfileId = filters.gymProfileId,
            let profile = gymProfiles.first(where: { $0.id == gymProfileId })
        else {
            return []
        }
        return Set(profile.allEquipment.filter(\.isActive).map(\.ref))
    }

    private func matching(_ exercises: [ExerciseModel]) -> [ExerciseModel] {
        let equipment = availableEquipment
        return exercises
            .filter { filters.matches($0, availableEquipment: equipment) }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }

    private func filterBySearchText(_ exercises: [ExerciseModel]) -> [ExerciseModel] {
        guard !normalizedSearchText.isEmpty else { return exercises }
        return exercises.filter { matchesSearchText($0, normalizedQuery: normalizedSearchText) }
    }

    /// Muscle group names are searchable too: "quads" should find a squat even though the word is
    /// in neither the name nor the description.
    private func matchesSearchText(_ exercise: ExerciseModel, normalizedQuery: String) -> Bool {
        if exercise.name.lowercased().contains(normalizedQuery) { return true }
        if let description = exercise.description?.lowercased(), description.contains(normalizedQuery) { return true }
        if exercise.alternateNames.contains(where: { $0.lowercased().contains(normalizedQuery) }) { return true }
        if exercise.muscleGroups.keys.contains(where: { $0.rawValue.lowercased().contains(normalizedQuery) }) { return true }
        return false
    }

    /// The name shown on the "Gym" chip.
    var gymFilterLabel: String {
        guard
            let gymProfileId = filters.gymProfileId,
            let profile = gymProfiles.first(where: { $0.id == gymProfileId })
        else {
            return "Gym"
        }
        return profile.name
    }

    func onResetFiltersPressed() {
        guard filters.isActive else { return }
        interactor.trackEvent(event: Event.filtersReset)
        filters.reset()
    }

    func onFilterChanged(_ name: String) {
        interactor.trackEvent(event: Event.filterChanged(name: name))
    }

    func onAddExercisePressed() {
        interactor.trackEvent(event: Event.onAddExercisePressed)
        router.showCreateExerciseView()
    }

    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case performExerciseSearchStart
        case performExerciseSearchSuccess(query: String, resultCount: Int)
        case performExerciseSearchFail(error: Error)
        case performExerciseSearchEmptyResults(query: String)
        case searchCleared
        case loadMyExercisesStart
        case loadMyExercisesSuccess(count: Int)
        case loadMyExercisesFail(error: Error)
        case loadOfficialExercisesStart
        case loadOfficialExercisesSuccess(count: Int)
        case loadOfficialExercisesFail(error: Error)
        case loadTopExercisesStart
        case loadTopExercisesSuccess(count: Int)
        case loadTopExercisesFail(error: Error)
        case incrementExerciseStart
        case incrementExerciseSuccess
        case incrementExerciseFail(error: Error)
        case syncExercisesFromCurrentUserStart
        case syncExercisesFromCurrentUserNoUid
        case syncExercisesFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncExercisesFromCurrentUserFail(error: Error)
        case onAddExercisePressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case officialSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onExercisePressedFromFavourites
        case onExercisePressedFromBookmarked
        case onExercisePressedFromTrending
        case onExercisePressedFromMyTemplates
        case filtersReset
        case filterChanged(name: String)

        var eventName: String {
            switch self {
            case .onAppear:                             return "ExercisesView_Appear"
            case .onDisappear:                          return "ExercisesView_Disappear"
            case .performExerciseSearchStart:           return "ExercisesView_Search_Start"
            case .performExerciseSearchSuccess:         return "ExercisesView_Search_Success"
            case .performExerciseSearchFail:            return "ExercisesView_Search_Fail"
            case .performExerciseSearchEmptyResults:    return "ExercisesView_Search_EmptyResults"
            case .searchCleared:                        return "ExercisesView_Search_Cleared"
            case .loadMyExercisesStart:                 return "ExercisesView_LoadMyExercises_Start"
            case .loadMyExercisesSuccess:               return "ExercisesView_LoadMyExercises_Success"
            case .loadMyExercisesFail:                  return "ExercisesView_LoadMyExercises_Fail"
            case .loadOfficialExercisesStart:           return "ExercisesView_LoadOfficialExercises_Start"
            case .loadOfficialExercisesSuccess:         return "ExercisesView_LoadOfficialExercises_Success"
            case .loadOfficialExercisesFail:            return "ExercisesView_LoadOfficialExercises_Fail"
            case .loadTopExercisesStart:                return "ExercisesView_LoadTopExercises_Start"
            case .loadTopExercisesSuccess:              return "ExercisesView_LoadTopExercises_Success"
            case .loadTopExercisesFail:                 return "ExercisesView_LoadTopExercises_Fail"
            case .incrementExerciseStart:               return "ExercisesView_IncrementExercise_Start"
            case .incrementExerciseSuccess:             return "ExercisesView_IncrementExercise_Success"
            case .incrementExerciseFail:                return "ExercisesView_IncrementExercise_Fail"
            case .syncExercisesFromCurrentUserStart:    return "ExercisesView_UserSync_Start"
            case .syncExercisesFromCurrentUserNoUid:    return "ExercisesView_UserSync_NoUID"
            case .syncExercisesFromCurrentUserSuccess:  return "ExercisesView_UserSync_Success"
            case .syncExercisesFromCurrentUserFail:     return "ExercisesView_UserSync_Fail"
            case .onAddExercisePressed:                 return "ExercisesView_AddExercisePressed"
            case .favouritesSectionViewed:              return "ExercisesView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:              return "ExercisesView_Bookmarked_SectionViewed"
            case .officialSectionViewed:                return "ExercisesView_Official_SectionViewed"
            case .trendingSectionViewed:                return "ExercisesView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:             return "ExercisesView_MyTemplates_SectionViewed"
            case .emptyStateShown:                      return "ExercisesView_EmptyState_Shown"
            case .onExercisePressedFromFavourites:      return "ExercisesView_ExercisePressed_Favourites"
            case .onExercisePressedFromBookmarked:      return "ExercisesView_ExercisePressed_Bookmarked"
            case .onExercisePressedFromTrending:        return "ExercisesView_ExercisePressed_Trending"
            case .onExercisePressedFromMyTemplates:     return "ExercisesView_ExercisePressed_MyTemplates"
            case .filtersReset:                         return "ExercisesView_Filters_Reset"
            case .filterChanged:                        return "ExercisesView_Filter_Changed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performExerciseSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performExerciseSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadMyExercisesSuccess(count: let count):
                return ["count": count]
            case .loadOfficialExercisesSuccess(count: let count):
                return ["count": count]
            case .loadTopExercisesSuccess(count: let count):
                return ["count": count]
            case .syncExercisesFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .filterChanged(name: let name):
                return ["filter": name]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .officialSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadMyExercisesFail(error: let error), .loadOfficialExercisesFail(error: let error), .loadTopExercisesFail(error: let error), .performExerciseSearchFail(error: let error), .incrementExerciseFail(error: let error), .syncExercisesFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadMyExercisesFail, .loadOfficialExercisesFail, .loadTopExercisesFail, .performExerciseSearchFail, .incrementExerciseFail, .syncExercisesFromCurrentUserFail:
                return .severe
            case .syncExercisesFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
        }
    }

}
