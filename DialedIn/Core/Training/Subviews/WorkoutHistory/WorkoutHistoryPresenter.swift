//
//  WorkoutHistoryPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutHistoryPresenter {
    private let interactor: WorkoutHistoryInteractor
    private let router: WorkoutHistoryRouter

    private(set) var isLoading = false
    
    var selectedSession: WorkoutSessionModel?

    var workoutSessions: [WorkoutSessionModel] {
        interactor.workoutSessions
            .sorted { ($0.dateCreated) > ($1.dateCreated) }
    }
    
    init(
        interactor: WorkoutHistoryInteractor,
        router: WorkoutHistoryRouter
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

    func onWorkoutSessionPressed(session: WorkoutSessionModel, layoutMode: LayoutMode) {
        selectedSession = session
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}

extension WorkoutHistoryPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case syncSessionsStart
        case syncSessionsSuccess
        case syncSessionsFail(error: Error)
        case loadInitialSessionsStart
        case loadInitialSessionsSuccess
        case loadInitialSessionsFail(error: Error)
        
        var eventName: String {
            switch self {
            case .onAppear:                     return "WorkoutHistoryView_Appear"
            case .onDisappear:                  return "WorkoutHistoryView_Disappear"
            case .syncSessionsStart:            return "WorkoutHistoryView_SyncSessions_Start"
            case .syncSessionsSuccess:          return "WorkoutHistoryView_SyncSessions_Success"
            case .syncSessionsFail:             return "WorkoutHistoryView_SyncSessions_Fail"
            case .loadInitialSessionsStart:     return "WorkoutHistoryView_LoadInitialSessions_Start"
            case .loadInitialSessionsSuccess:   return "WorkoutHistoryView_LoadInitialSessions_Success"
            case .loadInitialSessionsFail:      return "WorkoutHistoryView_LoadInitialSessions_Fail"
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
