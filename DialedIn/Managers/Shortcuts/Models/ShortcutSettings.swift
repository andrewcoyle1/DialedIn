//
//  ShortcutSettings.swift
//  DialedIn
//

import Foundation

/// Which quick actions the Add tab shows, and in what order.
///
/// Backs the Shortcuts screen, which was a `Text("Hello, World!")` under a "Toolbar" header with a
/// Save button whose action was empty. The Add tab's grid was four hardcoded buttons.
struct ShortcutSettings: DataSyncModelProtocol {

    var id: String = "shortcut_settings"
    var authorId: String

    /// Ordered `QuickAction.rawValue`s, or nil for the default set.
    ///
    /// The ordered visible list rather than a hidden set — the opposite of `AnalyticsSettings`,
    /// deliberately. Analytics sections have a fixed layout order, so storing what is hidden lets a
    /// newly added section appear for everyone. Here the order *is* the user's choice, so it has to
    /// be stored, which means an action added in a later release will not appear in a list that has
    /// already been curated. That is the right trade for a list someone arranged on purpose.
    var quickActionIds: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case quickActionIds = "quick_action_ids"
    }

    var eventParameters: [String: Any] {
        ["shortcut_quick_action_count": quickActions.count]
    }

    /// Unknown ids are dropped, so an action removed in a later release does not leave a gap, and a
    /// build that predates one does not fail to decode.
    var quickActions: [QuickAction] {
        guard let quickActionIds else { return QuickAction.defaultActions }
        return quickActionIds.compactMap { QuickAction(rawValue: $0) }
    }

    mutating func setQuickActions(_ actions: [QuickAction]) {
        quickActionIds = actions.map(\.rawValue)
    }

    static var mock: ShortcutSettings {
        ShortcutSettings(authorId: UserModel.mock.userId)
    }
}

/// Everything the Add tab can offer. Each case maps to a route `SearchRouter` already declares, so
/// this list is bounded by what that screen can actually reach.
enum QuickAction: String, CaseIterable, Identifiable, Codable {
    case startWorkout = "start_workout"
    case addExercise = "add_exercise"
    case logMeal = "log_meal"
    case logWeight = "log_weight"
    case browseWorkouts = "browse_workouts"
    case browseExercises = "browse_exercises"
    case browseRecipes = "browse_recipes"

    var id: String { rawValue }

    /// The four the grid was hardcoded to, so an existing user sees no change until they choose one.
    static let defaultActions: [QuickAction] = [.startWorkout, .addExercise, .logMeal, .logWeight]

    var title: String {
        switch self {
        case .startWorkout:    return "Start Workout"
        case .addExercise:     return "Add Exercise"
        case .logMeal:         return "Log Meal"
        case .logWeight:       return "Log Weight"
        case .browseWorkouts:  return "Workouts"
        case .browseExercises: return "Exercises"
        case .browseRecipes:   return "Recipes"
        }
    }

    var systemImage: String {
        switch self {
        case .startWorkout:    return "play.circle.fill"
        case .addExercise:     return "plus.circle.fill"
        case .logMeal:         return "fork.knife"
        case .logWeight:       return "scalemass"
        case .browseWorkouts:  return "figure.strengthtraining.traditional"
        case .browseExercises: return "dumbbell"
        case .browseRecipes:   return "book.closed"
        }
    }
}
