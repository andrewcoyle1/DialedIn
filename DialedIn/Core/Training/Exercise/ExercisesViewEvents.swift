//
//  ExercisesViewEvents.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation

enum ExercisesViewEvents: LoggableEvent {
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

    var eventName: String {
        switch self {
        case .performExerciseSearchStart:          return "ExercisesView_Search_Start"
        case .performExerciseSearchSuccess:        return "ExercisesView_Search_Success"
        case .performExerciseSearchFail:           return "ExercisesView_Search_Fail"
        case .performExerciseSearchEmptyResults:   return "ExercisesView_Search_EmptyResults"
        case .searchCleared:                         return "ExercisesView_Search_Cleared"
        case .loadMyExercisesStart:                return "ExercisesView_LoadMyExercises_Start"
        case .loadMyExercisesSuccess:              return "ExercisesView_LoadMyExercises_Success"
        case .loadMyExercisesFail:                 return "ExercisesView_LoadMyExercises_Fail"
        case .loadOfficialExercisesStart:          return "ExercisesView_LoadOfficialExercises_Start"
        case .loadOfficialExercisesSuccess:        return "ExercisesView_LoadOfficialExercises_Success"
        case .loadOfficialExercisesFail:           return "ExercisesView_LoadOfficialExercises_Fail"
        case .loadTopExercisesStart:               return "ExercisesView_LoadTopExercises_Start"
        case .loadTopExercisesSuccess:             return "ExercisesView_LoadTopExercises_Success"
        case .loadTopExercisesFail:                return "ExercisesView_LoadTopExercises_Fail"
        case .incrementExerciseStart:              return "ExercisesView_IncrementExercise_Start"
        case .incrementExerciseSuccess:            return "ExercisesView_IncrementExercise_Success"
        case .incrementExerciseFail:               return "ExercisesView_IncrementExercise_Fail"
        case .syncExercisesFromCurrentUserStart:   return "ExercisesView_UserSync_Start"
        case .syncExercisesFromCurrentUserNoUid:   return "ExercisesView_UserSync_NoUID"
        case .syncExercisesFromCurrentUserSuccess: return "ExercisesView_UserSync_Success"
        case .syncExercisesFromCurrentUserFail:    return "ExercisesView_UserSync_Fail"
        case .onAddExercisePressed:                return "ExercisesView_AddExercisePressed"
        case .favouritesSectionViewed:               return "ExercisesView_Favourites_SectionViewed"
        case .bookmarkedSectionViewed:               return "ExercisesView_Bookmarked_SectionViewed"
        case .officialSectionViewed:                 return "ExercisesView_Official_SectionViewed"
        case .trendingSectionViewed:                 return "ExercisesView_Trending_SectionViewed"
        case .myTemplatesSectionViewed:              return "ExercisesView_MyTemplates_SectionViewed"
        case .emptyStateShown:                       return "ExercisesView_EmptyState_Shown"
        case .onExercisePressedFromFavourites:     return "ExercisesView_ExercisePressed_Favourites"
        case .onExercisePressedFromBookmarked:     return "ExercisesView_ExercisePressed_Bookmarked"
        case .onExercisePressedFromTrending:       return "ExercisesView_ExercisePressed_Trending"
        case .onExercisePressedFromMyTemplates:    return "ExercisesView_ExercisePressed_MyTemplates"
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
