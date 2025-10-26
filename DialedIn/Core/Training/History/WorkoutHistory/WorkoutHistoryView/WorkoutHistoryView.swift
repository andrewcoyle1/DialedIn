//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutHistoryView: View {
    @Environment(DependencyContainer.self) private var container
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
        .screenAppearAnalytics(name: "WorkoutHistoryView")
        .scrollIndicators(.hidden)
        .navigationTitle("Workout Sessions")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadInitialSessions()
        }
        .onFirstTask {
            await viewModel.syncSessions()
        }
        .refreshable {
            await viewModel.syncSessions()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
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

#Preview("Functioning") {
    NavigationStack {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container)
            )
        )
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 10)))
    return NavigationStack {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(interactor: CoreInteractor(container: container))
        )
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(sessions: [])))
    return NavigationStack {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(interactor: CoreInteractor(container: container))
        )
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Remote Loading Failure") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 1, showErrorRemote: true)))
    
    return NavigationStack {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(interactor: CoreInteractor(container: container))
        )
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}

#Preview("Local Loading Failure") {
    let container = DevPreview.shared.container
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(
        services: MockWorkoutSessionServices(delay: 3, showErrorLocal: true)))
    
    return NavigationStack {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(interactor: CoreInteractor(container: container))
        )
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}
