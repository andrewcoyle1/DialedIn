//
//  WorkoutHistoryView.swift
//  DialedIn
//
//  Created by AI Assistant
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
                    Section {
                        emptyState
                    }
                } else {
                    Section {
                    listContents
                    } header: {
                        Text("Completed Workouts")
                    }
                }
            
        }
        .refreshable {
            await viewModel.syncSessions()
        }
        .screenAppearAnalytics(name: "WorkoutHistoryView")
        .onFirstTask {
            await viewModel.syncSessions()
        }
        .task {
            await viewModel.loadInitialSessions()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        // Navigation and alert handled by parent to preserve Section semantics inside List
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
    }
    
    private var listContents: some View {
        ForEach(viewModel.sessions) { session in
            WorkoutHistoryRow(session: session)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSession = session
                    // In compact/tabBar mode, open inspector; split view will route via onChange in parent
                    if layoutMode != .splitView { isShowingInspector = true }
                }
        }
    }
}

#Preview {
    @Previewable @State var isShowingInspector: Bool = false
    WorkoutHistoryView(
        viewModel: WorkoutHistoryViewModel(
            authManager: DevPreview.shared.authManager,
            workoutSessionManager: DevPreview.shared.workoutSessionManager,
            logManager: DevPreview.shared.logManager
        ),
        selectedSession: .constant(nil),
        isShowingInspector: $isShowingInspector
    )
    .previewEnvironment()
}

#Preview("Slow Loading") {
    @Previewable @State var isShowingInspector: Bool = false
    WorkoutHistoryView(
        viewModel: WorkoutHistoryViewModel(
            authManager: DevPreview.shared.authManager,
            workoutSessionManager: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 10)),
            logManager: DevPreview.shared.logManager
        ),
        selectedSession: .constant(nil),
        isShowingInspector: $isShowingInspector
    )
    .previewEnvironment()
}
