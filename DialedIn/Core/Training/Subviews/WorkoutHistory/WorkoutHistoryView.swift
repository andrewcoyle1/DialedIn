//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI
import SwiftfulRouting

struct WorkoutHistoryDelegate {
    let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
}

struct WorkoutHistoryView: View {
    @Environment(\.layoutMode) private var layoutMode
    
    @State var presenter: WorkoutHistoryPresenter

    var body: some View {
        List {
            if presenter.isLoading && presenter.sessions.isEmpty {
                loadingState
            } else if presenter.sessions.isEmpty {
                emptyState
            } else {
                listContents
            }
        }
        .navigationTitle("Workout Sessions")
        .toolbarTitleDisplayMode(.inlineLarge)
        .screenAppearAnalytics(name: "WorkoutHistoryView")
        .scrollIndicators(.hidden)
        .onAppear {
            presenter.loadInitialSessions()
        }
        .onFirstTask {
            await presenter.syncSessions()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
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
                    await presenter.syncSessions()
                }
            } label: {
                Text("Reload")
            }
        }
    }
    
    private var listContents: some View {
        Section {
            ForEach(presenter.sessions) { session in
                WorkoutHistoryRow(session: session)
                    .contentShape(Rectangle())
                    .anyButton(.highlight) {
                        presenter.onWorkoutSessionPressed(session: session, layoutMode: layoutMode)
                    }
            }
        } header: {
            HStack {
                Text("Completed Workouts")
                Spacer()
                Text("\(presenter.sessions.count)")
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

extension CoreBuilder {
    func workoutHistoryView(router: AnyRouter) -> some View {
        WorkoutHistoryView(
            presenter: WorkoutHistoryPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
        )
    }
}

extension CoreRouter {
    func showWorkoutHistoryView() {
        router.showScreen(.sheet) { router in
            builder.workoutHistoryView(router: router)
        }
    }
}

#Preview("Functioning") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.workoutHistoryView(router: router)
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    let container = DevPreview.shared.container()
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 10)))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.workoutHistoryView(router: router)
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container()
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(sessions: [])))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.workoutHistoryView(router: router)
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Remote Loading Failure") {
    let container = DevPreview.shared.container()
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 1, showErrorRemote: true)))
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.workoutHistoryView(router: router)
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Local Loading Failure") {
    let container = DevPreview.shared.container()
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(
        services: MockWorkoutSessionServices(delay: 3, showErrorLocal: true)))
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.workoutHistoryView(router: router)
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}
