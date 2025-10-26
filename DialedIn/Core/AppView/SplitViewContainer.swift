//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Observation

protocol SplitViewContainerInteractor {
    var activeSession: WorkoutSessionModel? { get }
    var isTrackerPresented: Bool { get }
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
}

extension CoreInteractor: SplitViewContainerInteractor { }

@Observable
@MainActor
class SplitViewContainerViewModel {
    private let interactor: SplitViewContainerInteractor
    private let workoutSessionManager: WorkoutSessionManager
    
    var preferredColumn: NavigationSplitViewColumn = .sidebar

    var activeSession: WorkoutSessionModel? {
        get {
            workoutSessionManager.activeSession
        }
        set {
            workoutSessionManager.activeSession = newValue
        }
    }
    
    var isTrackerPresented: Bool {
        get {
            workoutSessionManager.isTrackerPresented
        }
        set {
            workoutSessionManager.isTrackerPresented = newValue
        }
    }
    
    init(
        interactor: SplitViewContainerInteractor,
        workoutSessionManager: WorkoutSessionManager
    ) {
        self.interactor = interactor
        self.workoutSessionManager = workoutSessionManager
    }
    
    init(
        container: DependencyContainer
    ) {
        self.interactor = CoreInteractor(container: container)
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
    }
    
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        try interactor.getActiveLocalWorkoutSession()
    }
}

struct SplitViewContainer: View {
    @State var viewModel: SplitViewContainerViewModel
    @Environment(DependencyContainer.self) private var container
    @Bindable var detail: DetailNavigationModel
    @Bindable var appNavigation: AppNavigationModel

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $viewModel.preferredColumn) {
            // Sidebar
            List(selection: $appNavigation.selectedSection) {
                SwiftUI.Section {
                    ForEach(AppSection.allCases) { section in
                        NavigationLink(value: section) {
                            Label(section.title, systemImage: section.systemImage)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let active = viewModel.activeSession, !viewModel.isTrackerPresented {
                    TabViewAccessoryView(viewModel: TabViewAccessoryViewModel(interactor: CoreInteractor(container: container)), active: active)
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 150)
        } content: {
            NavigationStack {
                if let selectedSection = appNavigation.selectedSection {
                    switch selectedSection {
                    case .dashboard:
                        NavigationOptions.dashboard.viewForPage(container: container)
                    case .training:
                        NavigationOptions.training.viewForPage(container: container)
                    case .nutrition:
                        NavigationOptions.nutrition.viewForPage(container: container)
                    case .profile:
                        NavigationOptions.profile.viewForPage(container: container)
                    case .search:
                        NavigationOptions.search.viewForPage(container: container)
                    }
                } else {
                    NavigationOptions.dashboard.viewForPage(container: container)
                }
            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack(path: $detail.path) {
                detailPlaceholder
            }
            .navigationDestinationForCoreModule(path: $detail.path)
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                WorkoutTrackerView(viewModel: WorkoutTrackerViewModel(interactor: CoreInteractor(container: container), workoutSession: session), initialWorkoutSession: session)
            }
        }
        .task {
            // Load any active session from local storage when the SplitView appears
            if let active = try? viewModel.getActiveLocalWorkoutSession() {
                viewModel.activeSession = active
            }
        }
        .onChange(of: appNavigation.selectedSection) { _, _ in
            detail.clear()
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    SplitViewContainer(
        viewModel: SplitViewContainerViewModel(
            interactor: CoreInteractor(container: container),
            workoutSessionManager: container.resolve(WorkoutSessionManager.self)!
        ),
        detail: DetailNavigationModel(),
        appNavigation: AppNavigationModel()
    )
    .previewEnvironment()
}

private extension SplitViewContainer {
    var detailPlaceholder: some View {
        Text("Select an item to view details")
            .foregroundStyle(.secondary)
            .padding()
    }
}
