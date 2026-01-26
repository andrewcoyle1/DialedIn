//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct SplitViewContainer<TabAccessory: View>: View {

    @State var presenter: SplitViewContainerPresenter
    var tabs: [TabBarScreen]

    @ViewBuilder var tabViewAccessoryView: (AnyRouter, TabViewAccessoryDelegate) -> TabAccessory

    var body: some View {
        RouterView { router in
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
                    if let active = presenter.activeSession {
                        tabViewAccessoryView(router, TabViewAccessoryDelegate(active: active))
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
        }
        .navigationSplitViewStyle(.balanced)
    }
}

extension CoreBuilder {
    
    func splitViewContainer() -> some View {
        let tabs: [TabBarScreen] = [
            TabBarScreen(
                title: "Dashboard",
                systemImage: "house",
                screen: {
                    RouterView { router in
                        self.dashboardView(router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Nutrition",
                systemImage: "carrot",
                screen: {
                    RouterView { router in
                        self.nutritionView(router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Training",
                systemImage: "dumbbell",
                screen: {
                    RouterView { router in
                        self.trainingView(router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Profile",
                systemImage: "person",
                screen: {
                    RouterView { router in
                        self.profileView(router: router)
                    }
                    .any()
                }
            )
        ]
        
        return SplitViewContainer(
            presenter: SplitViewContainerPresenter(interactor: interactor),
            tabs: tabs,
            tabViewAccessoryView: { router, accessoryDelegate in
                self.tabViewAccessoryView(router: router, delegate: accessoryDelegate)
            }
        )
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
