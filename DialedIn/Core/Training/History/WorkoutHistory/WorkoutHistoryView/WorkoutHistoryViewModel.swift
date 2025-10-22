//
//  WorkoutHistoryViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutHistoryViewModel {
    private let authManager: AuthManager
    private let workoutSessionManager: WorkoutSessionManager
    private let logManager: LogManager
    
    private(set) var sessions: [WorkoutSessionModel] = []
    private(set) var isLoading = false
    
    var selectedSession: WorkoutSessionModel?
    var isShowingInspector: Bool = false
    var showAlert: AnyAppAlert?

    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func onWorkoutSessionPressed(session: WorkoutSessionModel, layoutMode: LayoutMode) {
        selectedSession = session
        if layoutMode != .splitView { isShowingInspector = true }
    }
    
    func loadInitialSessions() {
        guard !isLoading else { return }
        isLoading = true
        logManager.trackEvent(event: Event.loadInitialSessionsStart)
        defer { isLoading = false }
        
        do {
            guard let userId = authManager.auth?.uid else { return }
            
            // Load from local storage (limitTo: 0 means no limit)
            let fetchedSessions = try workoutSessionManager.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            logManager.trackEvent(event: Event.loadInitialSessionsSuccess)
            // Filter to only completed sessions (with endedAt)
            sessions = fetchedSessions.filter { $0.endedAt != nil }
                .sorted { ($0.dateCreated) > ($1.dateCreated) }
        } catch {
            logManager.trackEvent(event: Event.loadInitialSessionsFail(error: error))
            showAlert = AnyAppAlert(
                title: "We couldn't retrieve your sessions.",
                subtitle: "Please try again later."
            )
        }
    }
    
    func syncSessions() async {
        isLoading = true
        defer {
            isLoading = false
        }
        guard let userId = authManager.auth?.uid else { return }
        logManager.trackEvent(event: Event.syncSessionsStart)
        do {
            // Fetch from remote and merge into local
            try await workoutSessionManager.syncWorkoutSessionsFromRemote(authorId: userId)
            logManager.trackEvent(event: Event.syncSessionsSuccess)

            // Reload from local
            loadInitialSessions()

        } catch {
            logManager.trackEvent(event: Event.syncSessionsFail(error: error))
            showAlert = AnyAppAlert(
                title: "We couldn't retrieve your sessions.",
                subtitle: "Please check your internet connection and try again."
            )
        }
    }
    
    enum Event: LoggableEvent {
        case syncSessionsStart
        case syncSessionsSuccess
        case syncSessionsFail(error: Error)
        case loadInitialSessionsStart
        case loadInitialSessionsSuccess
        case loadInitialSessionsFail(error: Error)
        
        var eventName: String {
            switch self {
            case .syncSessionsStart:            return "WorkoutHistory_SyncSessions_Start"
            case .syncSessionsSuccess:          return "WorkoutHistory_SyncSessions_Success"
            case .syncSessionsFail:             return "WorkoutHistory_SyncSessions_Fail"
            case .loadInitialSessionsStart:     return "WorkoutHistory_LoadInitialSessions_Start"
            case .loadInitialSessionsSuccess:   return "WorkoutHistory_LoadInitialSessions_Success"
            case .loadInitialSessionsFail:      return "WorkoutHistory_LoadInitialSessions_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .syncSessionsFail(error: let error), .loadInitialSessionsFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .syncSessionsFail, .loadInitialSessionsFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
