//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by Andrew Coyle
//

import SwiftUI

struct WorkoutHistoryView: View {
    
    @State var viewModel: WorkoutHistoryViewModel
    @Environment(\.layoutMode) private var layoutMode
    
    @Binding var selectedSession: WorkoutSessionModel?
    @Binding var isShowingInspector: Bool
    
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
                    .onTapGesture {
                        selectedSession = session
                        // In compact/tabBar mode, open inspector; split view will route via onChange in parent
                        if layoutMode != .splitView { isShowingInspector = true }
                    }
            }
        } header: {
            Text("Completed Workouts")
        }
    }
}

#Preview("Functioning") {
    NavigationStack {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(
                container: DevPreview.shared.container
            ),
            selectedSession: Binding.constant(nil),
            isShowingInspector: Binding.constant(false)
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
            viewModel: WorkoutHistoryViewModel(container: container),
            selectedSession: .constant(nil),
            isShowingInspector: .constant(false)
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
            viewModel: WorkoutHistoryViewModel(container: container),
            selectedSession: .constant(nil),
            isShowingInspector: .constant(false)
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
            viewModel: WorkoutHistoryViewModel(container: container),
            selectedSession: .constant(nil),
            isShowingInspector: .constant(false)
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
            viewModel: WorkoutHistoryViewModel(container: container),
            selectedSession: .constant(nil),
            isShowingInspector: .constant(false)
        )
        .navigationTitle("Workout History")
    }
    .previewEnvironment()
}
