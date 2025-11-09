//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutHistoryView: View {
    @Environment(\.layoutMode) private var layoutMode
    
    @State var viewModel: WorkoutHistoryViewModel

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.sessions.isEmpty {
                loadingState
            } else if viewModel.sessions.isEmpty {
                emptyState
            } else {
                listContents
            }
        }
        .navigationTitle("Workout Sessions")
        .navigationBarTitleDisplayMode(.large)
        .screenAppearAnalytics(name: "WorkoutHistoryView")
        .scrollIndicators(.hidden)
        .showCustomAlert(alert: $viewModel.showAlert)
        .onAppear {
            viewModel.loadInitialSessions()
        }
        .onFirstTask {
            await viewModel.syncSessions()
        }
        .refreshable {
            await viewModel.syncSessions()
        }
    }
    
    private var loadingState: some View {
        VStack {
            ProgressView()
                .font(.system(size: 24))
                .padding(.top, 150)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .removeListRowFormatting()
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Workout History", systemImage: "clock.arrow.circlepath")
        } description: {
            Text("Complete your first workout to see it here")
        } actions: {
            Button {
                Task {
                    await viewModel.syncSessions()
                }
            } label: {
                Text("Reload")
            }
        }
    }
    
    private var listContents: some View {
        Section {
            ForEach(viewModel.sessions) { session in
                WorkoutHistoryRow(session: session)
                    .contentShape(Rectangle())
                    .anyButton(.highlight) {
                        viewModel.onWorkoutSessionPressed(session: session, layoutMode: layoutMode)
                    }
            }
        } header: {
            HStack {
                Text("Completed Workouts")
                Spacer()
                Text("\(viewModel.sessions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct WorkoutHistoryRow: View {
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

#Preview("Functioning") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.workoutHistoryView()
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 10)))
    let builder = CoreBuilder(container: container)
    return NavigationStack {
        builder.workoutHistoryView()
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(sessions: [])))
    let builder = CoreBuilder(container: container)
    return NavigationStack {
        builder.workoutHistoryView()
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Remote Loading Failure") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 1, showErrorRemote: true)))
    let builder = CoreBuilder(container: container)

    return NavigationStack {
        builder.workoutHistoryView()
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Local Loading Failure") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(
        services: MockWorkoutSessionServices(delay: 3, showErrorLocal: true)))
    let builder = CoreBuilder(container: container)

    return NavigationStack {
        builder.workoutHistoryView()
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}
