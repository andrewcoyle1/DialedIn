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

struct WorkoutHistoryView: View {
    @Environment(\.layoutMode) private var layoutMode
    @Environment(\.scenePhase) private var scenePhase
    
    @State var presenter: WorkoutHistoryPresenter

    var body: some View {
        List {
            if presenter.isLoading && presenter.workoutSessions.isEmpty {
                loadingState
            } else if presenter.workoutSessions.isEmpty {
                emptyState
            } else {
                listContents
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Workout Sessions")
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
    
    private var listContents: some View {
        Section {
            ForEach(presenter.workoutSessions) { session in
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
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.workoutHistoryView(router: router)
        .navigationTitle("Workout History")
    }
    
}

// #Preview("Slow Loading") {
//    let container = DevPreview.shared.container()
//    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 10)))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    return RouterView { router in
//        builder.workoutHistoryView(router: router)
//        .navigationTitle("Workout History")
//    }
//    
// }
//
// #Preview("No Data") {
//    let container = DevPreview.shared.container()
//    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(sessions: [])))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    return RouterView { router in
//        builder.workoutHistoryView(router: router)
//        .navigationTitle("Workout History")
//    }
//    
// }
//
// #Preview("Remote Loading Failure") {
//    let container = DevPreview.shared.container()
//    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 1, showErrorRemote: true)))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//
//    return RouterView { router in
//        builder.workoutHistoryView(router: router)
//        .navigationTitle("Workout History")
//    }
//    
// }
//
// #Preview("Local Loading Failure") {
//    let container = DevPreview.shared.container()
//    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(
//        services: MockWorkoutSessionServices(delay: 3, showErrorLocal: true)))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//
//    return RouterView { router in
//        builder.workoutHistoryView(router: router)
//        .navigationTitle("Workout History")
//    }
//    
// }
