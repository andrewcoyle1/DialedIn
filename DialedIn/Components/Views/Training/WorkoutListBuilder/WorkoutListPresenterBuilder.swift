//
//  WorkoutListPresenterBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutListPresenterBuilder {
    
    private let interactor: WorkoutListInteractorBuilder
    private let router: WorkoutListRouterBuilder

    private(set) var isLoading: Bool = false
    var systemWorkoutTemplates: [WorkoutTemplateModel] {
        interactor.systemWorkoutTemplates
            .sortedByKeyPath(keyPath: \.name, ascending: true)

    }
    
    var userWorkoutTemplates: [WorkoutTemplateModel] {
        interactor.userWorkoutTemplates
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var allWorkoutTemplates: [WorkoutTemplateModel] {
        interactor.allWorkoutTemplates
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var filteredWorkoutTemplates: [WorkoutTemplateModel] {
        self.allWorkoutTemplates
            .filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description?.lowercased().contains(searchText.lowercased()) == true ||
                $0.exercises.contains(where: { $0.exercise.name.lowercased().contains(searchText.lowercased()) })
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }
    
    var searchText: String = ""

    var selectedExerciseModel: ExerciseModel?
    var selectedWorkoutTemplate: WorkoutTemplateModel?
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
        
    var workoutsCount: Int {
        allWorkoutTemplates.count
    }
        
    init(
        interactor: WorkoutListInteractorBuilder,
        router: WorkoutListRouterBuilder
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
    
    func onAddWorkoutPressed() {
        interactor.trackEvent(event: Event.onAddWorkoutPressed)
        router.showCreateWorkoutView(delegate: CreateWorkoutDelegate(workoutTemplate: nil))
    }

    func onWorkoutPressed(
        workout: WorkoutTemplateModel,
        onWorkoutPressed: ((WorkoutTemplateModel) -> Void)? = nil
    ) {
        onWorkoutPressed?(workout)
    }

    #if DEV || MOCK
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    #endif
}

extension WorkoutListPresenterBuilder {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case performWorkoutSearchStart
        case performWorkoutSearchSuccess(query: String, resultCount: Int)
        case performWorkoutSearchFail(error: Error)
        case performWorkoutSearchEmptyResults(query: String)
        case searchCleared
        case loadSystemWorkoutsSuccess(count: Int)
        case loadSystemWorkoutsFail(error: Error)
        case loadMyWorkoutsStart
        case loadMyWorkoutsSuccess(count: Int)
        case loadMyWorkoutsFail(error: Error)
        case loadTopWorkoutsStart
        case loadTopWorkoutsSuccess(count: Int)
        case loadTopWorkoutsFail(error: Error)
        case incrementWorkoutStart
        case incrementWorkoutSuccess
        case incrementWorkoutFail(error: Error)
        case syncWorkoutsFromCurrentUserStart
        case syncWorkoutsFromCurrentUserNoUid
        case syncWorkoutsFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncWorkoutsFromCurrentUserFail(error: Error)
        case onAddWorkoutPressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case systemTemplatesSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onWorkoutPressedFromFavourites
        case onWorkoutPressedFromBookmarked
        case onWorkoutPressedFromTrending
        case onWorkoutPressedFromMyTemplates
        case onWorkoutPressedFromSystem

        var eventName: String {
            switch self {
            case .onAppear:                             return "WorkoutsView_Appear"
            case .onDisappear:                          return "WorkoutsView_Disappear"
            case .performWorkoutSearchStart:            return "WorkoutsView_Search_Start"
            case .performWorkoutSearchSuccess:          return "WorkoutsView_Search_Success"
            case .performWorkoutSearchFail:             return "WorkoutsView_Search_Fail"
            case .performWorkoutSearchEmptyResults:     return "WorkoutsView_Search_EmptyResults"
            case .searchCleared:                        return "WorkoutsView_Search_Cleared"
            case .loadSystemWorkoutsSuccess:            return "WorkoutsView_LoadSystemWorkouts_Success"
            case .loadSystemWorkoutsFail:               return "WorkoutsView_LoadSystemWorkouts_Fail"
            case .loadMyWorkoutsStart:                  return "WorkoutsView_LoadMyWorkouts_Start"
            case .loadMyWorkoutsSuccess:                return "WorkoutsView_LoadMyWorkouts_Success"
            case .loadMyWorkoutsFail:                   return "WorkoutsView_LoadMyWorkouts_Fail"
            case .loadTopWorkoutsStart:                 return "WorkoutsView_LoadTopWorkouts_Start"
            case .loadTopWorkoutsSuccess:               return "WorkoutsView_LoadTopWorkouts_Success"
            case .loadTopWorkoutsFail:                  return "WorkoutsView_LoadTopWorkouts_Fail"
            case .incrementWorkoutStart:                return "WorkoutsView_IncrementWorkout_Start"
            case .incrementWorkoutSuccess:              return "WorkoutsView_IncrementWorkout_Success"
            case .incrementWorkoutFail:                 return "WorkoutsView_IncrementWorkout_Fail"
            case .syncWorkoutsFromCurrentUserStart:     return "WorkoutsView_UserSync_Start"
            case .syncWorkoutsFromCurrentUserNoUid:     return "WorkoutsView_UserSync_NoUID"
            case .syncWorkoutsFromCurrentUserSuccess:   return "WorkoutsView_UserSync_Success"
            case .syncWorkoutsFromCurrentUserFail:      return "WorkoutsView_UserSync_Fail"
            case .onAddWorkoutPressed:                  return "WorkoutsView_AddWorkoutPressed"
            case .favouritesSectionViewed:              return "WorkoutsView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:              return "WorkoutsView_Bookmarked_SectionViewed"
            case .systemTemplatesSectionViewed:         return "WorkoutsView_SystemTemplates_SectionViewed"
            case .trendingSectionViewed:                return "WorkoutsView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:             return "WorkoutsView_MyTemplates_SectionViewed"
            case .emptyStateShown:                      return "WorkoutsView_EmptyState_Shown"
            case .onWorkoutPressedFromFavourites:       return "WorkoutsView_WorkoutPressed_Favourites"
            case .onWorkoutPressedFromBookmarked:       return "WorkoutsView_WorkoutPressed_Bookmarked"
            case .onWorkoutPressedFromTrending:         return "WorkoutsView_WorkoutPressed_Trending"
            case .onWorkoutPressedFromMyTemplates:      return "WorkoutsView_WorkoutPressed_MyTemplates"
            case .onWorkoutPressedFromSystem:           return "WorkoutsView_WorkoutPressed_System"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performWorkoutSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performWorkoutSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadSystemWorkoutsSuccess(count: let count):
                return ["count": count]
            case .loadMyWorkoutsSuccess(count: let count):
                return ["count": count]
            case .loadTopWorkoutsSuccess(count: let count):
                return ["count": count]
            case .syncWorkoutsFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .systemTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadSystemWorkoutsFail(error: let error), .loadMyWorkoutsFail(error: let error), .loadTopWorkoutsFail(error: let error), .performWorkoutSearchFail(error: let error), .incrementWorkoutFail(error: let error), .syncWorkoutsFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadSystemWorkoutsFail, .loadMyWorkoutsFail, .loadTopWorkoutsFail, .performWorkoutSearchFail, .incrementWorkoutFail, .syncWorkoutsFromCurrentUserFail:
                return .severe
            case .syncWorkoutsFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
        }
    }

}
