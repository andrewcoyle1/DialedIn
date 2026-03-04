//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutHistoryDelegate {
    let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
}

struct WorkoutHistoryView<WorkoutSessionRow: View>: View {
    @Environment(\.layoutMode) private var layoutMode
    @Environment(\.scenePhase) private var scenePhase
    
    @State var presenter: WorkoutHistoryPresenter

    @ViewBuilder var workoutSessionRow: (WorkoutSessionRowDelegate) -> WorkoutSessionRow

    var body: some View {
        List {
            if presenter.isLoading && presenter.workoutSessions.isEmpty {
                loadingState
            } else if let user = presenter.currentUser {
                listContents(user: user)
            } else {
                emptyState
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
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
                // TODO: Implement force read function here
            } label: {
                Text("Reload")
            }
        }
    }
    
    private func listContents(user: UserModel) -> some View {
        Section {
            ForEach(presenter.workoutSessions) { session in
                workoutSessionRow(WorkoutSessionRowDelegate(session: session, author: user))
                    .anyButton(.highlight) {
                        presenter.onWorkoutSessionPressed(session: session, layoutMode: layoutMode)
                    }
            }
            .removeListRowFormatting()
        } header: {
            HStack {
                Text("Completed Workouts")
                Spacer()
                Text("\(presenter.workoutSessions.count)")
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
                .foregroundStyle(Color.accentColor)
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
            presenter: WorkoutHistoryPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            workoutSessionRow: { delegate in
                self.workoutSessionRowView(router: router, delegate: delegate)
            }
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
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.workoutHistoryView(router: router)
        .navigationTitle("Workout History")
    }
    
}

#Preview("No Data") {
    let container = DevPreview.shared.container()
    let userWorkoutSessionSyncEngine = CollectionSyncEngine<WorkoutSessionModel>(
        remote: MockRemoteCollectionService(collection: []),
        managerKey: Keys.userWorkoutSessionManagerKey
    )
    let followingWorkoutSessionSyncEngine = CollectionGroupSyncEngine<WorkoutSessionModel>(
        remote: MockRemoteCollectionGroupService(collection: []),
        managerKey: Keys.followingWorkoutSessionsManagerKey
    )
    
    let activeWorkoutSessionPersistence = FileManagerDocumentPersistence<WorkoutSessionModel>()
    
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(activeWorkoutSessionPersistence: activeWorkoutSessionPersistence, userWorkoutSessionSyncEngine: userWorkoutSessionSyncEngine, followingWorkoutSessionSyncEngine: followingWorkoutSessionSyncEngine))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.workoutHistoryView(router: router)
            .navigationTitle("Workout History")
    }
    
}
