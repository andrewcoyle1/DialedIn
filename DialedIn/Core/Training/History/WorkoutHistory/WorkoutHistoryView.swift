//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by AI Assistant
//

import SwiftUI

struct WorkoutHistoryView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(AuthManager.self) private var authManager
    @Environment(\.layoutMode) private var layoutMode
    
    @State private var sessions: [WorkoutSessionModel] = []
    @State private var isLoading = false
    @State private var hasMorePages = true
    @State private var currentLimit = 20
    @Binding var alert: AnyAppAlert?
    @Binding var selectedSession: WorkoutSessionModel?
    @Binding var isShowingInspector: Bool
    
    var body: some View {
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
                if hasMorePages && !isLoading {
                    Button {
                        Task { await loadMoreSessions() }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Load More")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        } header: {
            Text(sectionHeaderTitle)
        }
        .screenAppearAnalytics(name: "WorkoutHistoryView")
        .task(id: authManager.auth?.uid) {
            await loadInitialSessions()
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
        defer { isLoading = false }
        
        do {
            guard let userId = authManager.auth?.uid else { return }
            
            let fetchedSessions = try await sessionManager.getWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: currentLimit
            )
            
            // Filter to only completed sessions (with endedAt)
            sessions = fetchedSessions.filter { $0.endedAt != nil }
                .sorted { ($0.dateCreated) > ($1.dateCreated) }
            
            // Check if there might be more
            hasMorePages = fetchedSessions.count >= currentLimit
        } catch {
            alert = AnyAppAlert(error: error)
        }
    }
    
    private func loadMoreSessions() async {
        guard !isLoading && hasMorePages else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let userId = authManager.auth?.uid else { return }
            
            let previousCount = sessions.count
            currentLimit += 20
            
            let fetchedSessions = try await sessionManager.getWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: currentLimit
            )
            
            // Filter to only completed sessions (with endedAt)
            let completedSessions = fetchedSessions.filter { $0.endedAt != nil }
                .sorted { ($0.dateCreated) > ($1.dateCreated) }
            
            sessions = completedSessions
            
            // Check if we got more sessions than before
            hasMorePages = completedSessions.count > previousCount && fetchedSessions.count >= currentLimit
        } catch {
            alert = AnyAppAlert(error: error)
        }
    }
}

struct WorkoutHistoryRow: View {
    let session: WorkoutSessionModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            // Workout info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if let endedAt = session.endedAt {
                        Text(session.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        let duration = endedAt.timeIntervalSince(session.dateCreated)
                        Text(Date.formatDuration(duration))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var isShowingInspector: Bool = false
    List {
        WorkoutHistoryView(alert: .constant(nil), selectedSession: .constant(nil), isShowingInspector: $isShowingInspector)
    }
    .previewEnvironment()
}
