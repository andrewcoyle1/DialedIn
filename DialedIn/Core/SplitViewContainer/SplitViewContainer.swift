//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct SplitViewContainer: View {

    @State var presenter: SplitViewContainerPresenter
    var tabs: [TabBarScreen]

    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryDelegate) -> AnyView
    @ViewBuilder var workoutTrackerView: (WorkoutTrackerDelegate) -> AnyView

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $presenter.preferredColumn) {
            // Sidebar
            List {
                Section {
                    ForEach(tabs) { tab in
                        Button {
                            print("Tab selected")
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let active = presenter.activeSession, !presenter.isTrackerPresented {
                    tabViewAccessoryView(TabViewAccessoryDelegate(active: active))
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 150)
        } content: {
            tabs.first!.screen()
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack {
                detailPlaceholder
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: Binding(get: {
            presenter.isTrackerPresented
        }, set: { newValue in
            presenter.isTrackerPresented = newValue
        })) {
            if let session = presenter.activeSession {
                workoutTrackerView(WorkoutTrackerDelegate(workoutSession: session))
            }
        }
        .task {
            // Load any active session from local storage when the SplitView appears
            if let active = try? presenter.getActiveLocalWorkoutSession() {
                presenter.activeSession = active
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.splitViewContainer()
    .previewEnvironment()
}

private extension SplitViewContainer {
    var detailPlaceholder: some View {
        Text("Select an item to view details")
            .foregroundStyle(.secondary)
            .padding()
    }
}
