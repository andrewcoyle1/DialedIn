//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct SplitViewDelegate {
    var path: Binding<[TabBarPathOption]>
    var tab: Binding<TabBarOption>
}

struct SplitViewContainer: View {
    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: SplitViewContainerViewModel

    var delegate: SplitViewDelegate

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $viewModel.preferredColumn) {
            // Sidebar
            List {
                Section {
                    ForEach(TabBarOption.allCases, id: \.self) { section in
                        Button {
                            delegate.tab.wrappedValue = section
                        } label: {
                            Label(section.id, systemImage: section.symbolName)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let active = viewModel.activeSession, !viewModel.isTrackerPresented {
                    let delegate = TabViewAccessoryViewDelegate(active: active)
                    builder.tabViewAccessoryView(delegate: delegate)
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 150)
        } content: {
            NavigationStack {
                delegate.tab.wrappedValue.viewForPage(builder: builder, path: delegate.path)
            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack(path: delegate.path) {
                detailPlaceholder
            }
            .navDestinationForTabBarModule(path: delegate.path)
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                builder.workoutTrackerView(delegate: WorkoutTrackerViewDelegate(workoutSession: session))
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
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard
    let delegate = SplitViewDelegate(path: $path, tab: $tab)
    let container = DevPreview.shared.container
    SplitViewContainer(
        viewModel: SplitViewContainerViewModel(
            interactor: CoreInteractor(container: container)
        ),
        delegate: delegate
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
