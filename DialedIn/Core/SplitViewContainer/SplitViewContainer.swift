//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct SplitViewContainer: View {

    @State var presenter: SplitViewContainerPresenter
    var tabs: [TabBarScreen]

    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryDelegate) -> AnyView

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
