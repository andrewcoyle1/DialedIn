//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarScreen: Identifiable {
    var id: String {
        title
    }

    let title: String
    let systemImage: String
    @ViewBuilder var screen: () -> AnyView
}

struct TabBarView<TrainingTabAccessory: View, MealTabAccessory: View, Search: View>: View {

    @State var presenter: TabBarPresenter

    var tabs: [TabBarScreen]
    
    @ViewBuilder var trainingAccessoryView: (TrainingAccessoryDelegate) -> TrainingTabAccessory
    @ViewBuilder var mealAccessoryView: (MealAccessoryDelegate) -> MealTabAccessory
    
    @ViewBuilder var searchView: () -> Search
        
    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                Tab {
                    tab.screen()
                } label: {
                    Label(tab.title, systemImage: tab.systemImage)
                }
            }

            Tab(role: .search) {
                searchView()
            } label: {
                Image(systemName: "plus")
            }

        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory(isEnabled: presenter.showTabAccessory) {
            ScrollView(.horizontal) {
                HStack(alignment: .center) {
                    if let active = presenter.activeSession {
                        trainingAccessoryView(TrainingAccessoryDelegate(active: active))
                            .frame(width: presenter.tabAccessoryWidth)
                    }
                    if let draftMeal = presenter.draftMeal {
                        mealAccessoryView(MealAccessoryDelegate(draftMeal: draftMeal))
                            .frame(width: presenter.tabAccessoryWidth)
                    }
                }
                //                    .frame(width: geometry.size.height)
                .scrollTargetLayout()
            }
            //                .padding(.horizontal)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            //                .frame(maxHeight: .infinity)
            .background {
                GeometryReader { geo in
                    Color.clear.preference(key: WidthPreferenceKey.self, value: geo.size.width)
                }
            }
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                self.presenter.tabAccessoryWidth = width
            }
        }
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 400
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension CoreBuilder {
    
    func tabBarView(router: AnyRouter) -> some View {

        let tabs: [TabBarScreen] = [
            TabBarScreen(
                title: "Dashboard",
                systemImage: "house",
                screen: {
                    RouterView { router in
                        self.dashboardView(router: router, delegate: DashboardDelegate())
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Training",
                systemImage: "dumbbell",
                screen: {
                    RouterView { router in
                        self.trainingView(delegate: TrainingDelegate(), router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Nutrition",
                systemImage: "carrot",
                screen: {
                    RouterView { router in
                        self.nutritionView(delegate: NutritionDelegate(), router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Analytics",
                systemImage: "chart.bar.xaxis",
                screen: {
                    RouterView { router in
                        self.analyticsView(delegate: AnalyticsDelegate(), router: router)
                    }
                    .any()
                }
            )
        ]

        return TabBarView(
            presenter: TabBarPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            tabs: tabs,
            trainingAccessoryView: { delegate in
                self.trainingAccessoryView(router: router, delegate: delegate)
            },
            mealAccessoryView: { delegate in
                self.mealAccessoryView(router: router, delegate: delegate)
            },
            searchView: {
                RouterView { router in
                    self.searchView(router: router)
                }
            }
        )
    }
}

#Preview("Has No Active Session") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.tabBarView(router: router)
    }
    
}

#Preview("Has Active Session") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.tabBarView(router: router)
    }
    
}
