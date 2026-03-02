//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct SplitViewContainer<TabAccessory: View>: View {

    @State var presenter: SplitViewContainerPresenter
    var tabs: [TabBarScreen]

    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryDelegate) -> TabAccessory

    var body: some View {
        RouterView { _ in
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
        }
        .navigationSplitViewStyle(.balanced)
    }
}

extension CoreBuilder {
    
    func splitViewContainer(router: AnyRouter) -> some View {
        let tabs: [TabBarScreen] = [
            TabBarScreen(
                title: "Analytics",
                systemImage: "house",
                screen: {
                    self.analyticsView(delegate: AnalyticsDelegate(), router: router)
                    .any()
                }
            ),
            TabBarScreen(
                title: "Training",
                systemImage: "dumbbell",
                screen: {
                    self.trainingView(delegate: TrainingDelegate(), router: router)
                    .any()
                }
            ),
            TabBarScreen(
                title: "Nutrition",
                systemImage: "carrot",
                screen: {
                    self.nutritionView(delegate: NutritionDelegate(), router: router)
                    .any()
                }
            )
        ]
        
        return SplitViewContainer(
            presenter: SplitViewContainerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            tabs: tabs,
            tabViewAccessoryView: { accessoryDelegate in
                self.tabViewAccessoryView(router: router, delegate: accessoryDelegate)
            }
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.splitViewContainer(router: router)
    }
    
}

private extension SplitViewContainer {
    var detailPlaceholder: some View {
        Text("Select an item to view details")
            .foregroundStyle(.secondary)
            .padding()
    }
}
