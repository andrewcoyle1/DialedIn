//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct SplitViewContainer: View {
    @Environment(DependencyContainer.self) private var container

    @State var viewModel: SplitViewContainerViewModel

    @Binding var path: [TabBarPathOption]
    @Binding var tab: TabBarOption

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $viewModel.preferredColumn) {
            // Sidebar
            List {
                Section {
                    ForEach(TabBarOption.allCases, id: \.self) { section in
                        Button {
                            tab = section
                        } label: {
                            Label(section.id, systemImage: section.symbolName)
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
                tab.viewForPage(container: container, path: $path)
            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack(path: $path) {
                detailPlaceholder
            }
            .navDestinationForTabBarModule(path: $path)
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
    }
}

#Preview {
    let container = DevPreview.shared.container
    SplitViewContainer(
        viewModel: SplitViewContainerViewModel(
            interactor: CoreInteractor(container: container)
        ),
        path: .constant([]),
        tab: .constant(.dashboard)
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
