//
//  WorkoutHistoryViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

protocol WorkoutHistoryInteractor {
    var auth: UserAuthInfo? { get }
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func syncWorkoutSessionsFromRemote(authorId: String, limitTo: Int) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: WorkoutHistoryInteractor { }

@MainActor
protocol WorkoutHistoryRouter {
    func showDevSettingsView()
}

extension CoreRouter: WorkoutHistoryRouter { }

@Observable
@MainActor
class WorkoutHistoryViewModel {
    private let interactor: WorkoutHistoryInteractor
    private let router: WorkoutHistoryRouter

    private(set) var sessions: [WorkoutSessionModel] = []
    private(set) var isLoading = false
    
    var selectedSession: WorkoutSessionModel?
    var showAlert: AnyAppAlert?

    init(
        interactor: WorkoutHistoryInteractor,
        router: WorkoutHistoryRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onWorkoutSessionPressed(session: WorkoutSessionModel, layoutMode: LayoutMode, onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?) {
        selectedSession = session
        onSessionSelectionChanged?(session)
    }
    
    func loadInitialSessions() {
        guard !isLoading else { return }
        isLoading = true
        interactor.trackEvent(event: Event.loadInitialSessionsStart)
        defer { isLoading = false }
        
        do {
            guard let userId = interactor.auth?.uid else { return }
            
            // Load from local storage (limitTo: 0 means no limit)
            let fetchedSessions = try interactor.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            interactor.trackEvent(event: Event.loadInitialSessionsSuccess)
            // Filter to only completed sessions (with endedAt)
            sessions = fetchedSessions.filter { $0.endedAt != nil }
                .sorted { ($0.dateCreated) > ($1.dateCreated) }
        } catch {
            interactor.trackEvent(event: Event.loadInitialSessionsFail(error: error))
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
        guard let userId = interactor.auth?.uid else { return }
        interactor.trackEvent(event: Event.syncSessionsStart)
        do {
            // Fetch from remote and merge into local
            try await interactor.syncWorkoutSessionsFromRemote(authorId: userId, limitTo: 100)
            interactor.trackEvent(event: Event.syncSessionsSuccess)

            // Reload from local
            loadInitialSessions()

        } catch {
            interactor.trackEvent(event: Event.syncSessionsFail(error: error))
            showAlert = AnyAppAlert(
                title: "We couldn't retrieve your sessions.",
                subtitle: "Please check your internet connection and try again."
            )
        }
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
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
