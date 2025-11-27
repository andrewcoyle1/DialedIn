//
//  WorkoutSummaryCardPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutSummaryCardPresenter {
    private let interactor: WorkoutSummaryCardInteractor
    private let router: WorkoutSummaryCardRouter

    private(set) var session: WorkoutSessionModel?
    private(set) var isLoading = true

    init(
        interactor: WorkoutSummaryCardInteractor,
        router: WorkoutSummaryCardRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func calculateTotalVolume(session: WorkoutSessionModel) -> Double {
        session.exercises.flatMap { $0.sets }
            .filter { $0.completedAt != nil }
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    func loadSession(scheduledWorkout: ScheduledWorkout) async {
        guard let sessionId = scheduledWorkout.completedSessionId else {
            isLoading = false
            return
        }
        
        interactor.trackEvent(event: Event.loadSessionStart)
        do {
            let fetchedSession = try await interactor.getWorkoutSessionWithFallback(id: sessionId)
            await MainActor.run {
                self.session = fetchedSession
                self.isLoading = false
                interactor.trackEvent(event: Event.loadSessionSuccess)
            }
        } catch {
            interactor.trackEvent(event: Event.loadSessionFail(error: error))
            await MainActor.run {
                self.isLoading = false
                self.router.showAlert(error: error)
            }
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case loadSessionStart
        case loadSessionSuccess
        case loadSessionFail(error: Error)
        
        var eventName: String {
            switch self {
            case .loadSessionStart:     return "WorkoutSummaryCard_LoadSession_Start"
            case .loadSessionSuccess:   return "WorkoutSummaryCard_LoadSession_Success"
            case .loadSessionFail:      return "WorkoutSummaryCard_LoadSession_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadSessionFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadSessionFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
