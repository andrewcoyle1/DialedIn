//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by AI Assistant
//

import SwiftUI

@Observable
@MainActor
class WorkoutHistoryViewModel {
    
}

struct WorkoutHistoryView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(AuthManager.self) private var authManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.layoutMode) private var layoutMode
    
    @State private var sessions: [WorkoutSessionModel] = []
    @State private var isLoading = false
    @Binding var alert: AnyAppAlert?
    @Binding var selectedSession: WorkoutSessionModel?
    @Binding var isShowingInspector: Bool
    
    var body: some View {
        List {
            Section {
                if isLoading {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(Color.white)
                            Spacer()
                        }
                        Spacer()
                    }
                    .removeListRowFormatting()
                } else if sessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("No Workout History")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Complete your first workout to see it here")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    ForEach(sessions) { session in
                        WorkoutHistoryRow(session: session)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedSession = session
                                // In compact/tabBar mode, open inspector; split view will route via onChange in parent
                                if layoutMode != .splitView { isShowingInspector = true }
                            }
                    }
                }
            } header: {
                Text(sectionHeaderTitle)
            }
        }
        .refreshable {
            await syncSessions()
        }
        .screenAppearAnalytics(name: "WorkoutHistoryView")
        .task(id: authManager.auth?.uid) {
            await loadInitialSessions()
        }
        .onChange(of: sessionManager.sessionsLastModified) { _, _ in
            // Reload when any session is deleted/edited (works for both inspector and split view)
            Task { await loadInitialSessions() }
        }
        .onChange(of: isShowingInspector) { oldValue, newValue in
            // Reload sessions when inspector is dismissed (to reflect any deletions/edits)
            if oldValue && !newValue {
                Task { await loadInitialSessions() }
            }
        }
        .onChange(of: selectedSession) { oldValue, newValue in
            // Reload sessions when returning from detail view in split view (session cleared after deletion)
            if oldValue != nil && newValue == nil {
                Task { await loadInitialSessions() }
            }
        }
        // Navigation and alert handled by parent to preserve Section semantics inside List
    }
    
    private var sectionHeaderTitle: String {
        if isLoading { return "Loading" }
        if sessions.isEmpty { return "Empty" }
        return "Completed Workouts"
    }
    
    private func loadInitialSessions() async {
        guard !isLoading else { return }
        isLoading = true
        logManager.trackEvent(event: Event.loadInitialSessionsStart)
        defer { isLoading = false }
        
        do {
            guard let userId = authManager.auth?.uid else { return }
            
            // Load from local storage (limitTo: 0 means no limit)
            let fetchedSessions = try sessionManager.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            logManager.trackEvent(event: Event.loadInitialSessionsSuccess)
            // Filter to only completed sessions (with endedAt)
            sessions = fetchedSessions.filter { $0.endedAt != nil }
                .sorted { ($0.dateCreated) > ($1.dateCreated) }
        } catch {
            logManager.trackEvent(event: Event.loadInitialSessionsFail(error: error))
            alert = AnyAppAlert(error: error)
        }
    }
    
    private func syncSessions() async {
        guard let userId = authManager.auth?.uid else { return }
        logManager.trackEvent(event: Event.syncSessionsStart)
        do {
            // Fetch from remote and merge into local
            try await sessionManager.syncWorkoutSessionsFromRemote(authorId: userId)
            logManager.trackEvent(event: Event.syncSessionsSuccess)

            // Reload from local
            await loadInitialSessions()

        } catch {
            logManager.trackEvent(event: Event.syncSessionsFail(error: error))
            alert = AnyAppAlert(error: error)
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

#Preview {
    @Previewable @State var isShowingInspector: Bool = false
    List {
        WorkoutHistoryView(alert: .constant(nil), selectedSession: .constant(nil), isShowingInspector: $isShowingInspector)
    }
    .previewEnvironment()
}
