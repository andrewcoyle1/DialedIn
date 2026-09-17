//
//  NutritionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct NutritionDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct NutritionView<
    CalendarHeaderView: View,
    MealHeader: View
>: View {
    
    @State var presenter: NutritionPresenter
    let delegate: NutritionDelegate
    let profileTransitionId: String = "profile_button_transition"
    
    @ViewBuilder var calendarHeader: (CalendarHeaderDelegate, Binding<Bool>) -> CalendarHeaderView
    @ViewBuilder var mealHourHeader: (MealHourHeaderDelegate) -> MealHeader
    @Namespace private var namespace

    @State private var isCalendarExpanded = false

    var body: some View {
        List {
            mealLogSection
            moreSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { presenter.onViewAppear(delegate: delegate) }
        .onDisappear { presenter.onViewDisappear(delegate: delegate) }
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .top) {
            topSafeAreaSection
        }
    }
    
    @ViewBuilder
    private var topSafeAreaSection: some View {
        VStack(spacing: 0) {
            if presenter.showCalendarWeekBanner {
                calendarHeader(
                    CalendarHeaderDelegate(
                        onDatePressed: { date in
                            presenter.selectedDate = date.startOfDay
                        },
                        markersByDay: {
                            presenter.calorieMarkersByDay()
                        }
                    ),
                    $isCalendarExpanded
                )
            }
            if let dailyTotals = presenter.dailyTotals,
            let dailyTarget = presenter.dailyTarget {
                MacroHeader(
                    dailyTotals: dailyTotals,
                    dailyTarget: dailyTarget,
                    showCaloriesRing: presenter.showCaloriesRing,
                    showProteinRing: presenter.showProteinRing,
                    showFatRing: presenter.showFatRing,
                    showCarbsRing: presenter.showCarbsRing
                )
            }
        }
        .background(.bar)
    }
    
    // MARK: - Timeline

    /// The day's meals, an hour at a time. `presenter.timelineHours` has already dropped the empty
    /// hours if the setting asks for it, so there is nothing to filter here.
    private var mealLogSection: some View {
        ForEach(presenter.timelineHours) { timelineHour in
            hourHeaderSection(timelineHour)
            mealSections(timelineHour)
        }
        .listRowSeparator(.hidden)
        .listSectionMargins(.vertical, 0)
        .listSectionSpacing(0)
    }

    private func hourHeaderSection(_ timelineHour: NutritionPresenter.TimelineHour) -> some View {
        Section {
            mealHourHeader(
                MealHourHeaderDelegate(hour: timelineHour.hour, meals: timelineHour.meals)
            )
        }
        .listSectionMargins(.horizontal, 0)
        .padding(.horizontal)
    }

    /// A section per meal, so the items logged together stay grouped under one time.
    private func mealSections(_ timelineHour: NutritionPresenter.TimelineHour) -> some View {
        ForEach(timelineHour.meals) { meal in
            Section {
                ForEach(meal.items) { item in
                    mealItemRow(item, meal: meal)
                }
            }
        }
    }

    private func mealItemRow(_ item: MealItemModel, meal: MealLogModel) -> some View {
        MealItemRowView(
            item: item,
            timestamp: presenter.timestamp(for: item, in: meal),
            style: presenter.mealItemRowStyle,
            onEditPressed: { mealItem in
                presenter.onEditMealItem(mealItem)
            }
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                presenter.deleteMealItem(item, from: meal)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                presenter.onViewMealPressed(meal)
            } label: {
                Label("Meal", systemImage: "list.bullet.rectangle")
            }
        }
    }

    // MARK: - More

    private var moreSection: some View {
        Section {
            Group {
                Label("Nutrition Overview", systemImage: "list.bullet")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .tappableBackground()
                    .anyButton {
                        presenter.onNutritionOverviewPressed()
                    }
                Label("Customise Food Log", systemImage: "slider.horizontal.3")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .tappableBackground()
                    .anyButton {
                        presenter.onCustomiseFoodLogPressed()
                    }
            }
            .foregroundStyle(.primary)
        } header: {
            Text("More")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        
        #if DEV || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        #endif
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isCalendarExpanded = true
            } label: {
                Image(systemName: "calendar")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onTimelineActionsPressed()
            } label: {
                Image(systemName: "line.3.horizontal")
            }
        }
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButton(
                action: {
                    presenter.onProfilePressed(transitionId: profileTransitionId, namespace: namespace)
                },
                imageUrl: presenter.userImageUrl
            )
            .matchedTransitionSource(id: profileTransitionId, in: namespace)
        }
    }
}

extension CoreRouter {
    func showNutritionView() {
        router.showScreen(.push) { router in
            builder.nutritionView(delegate: NutritionDelegate(), router: router)
        }
    }
}

extension CoreBuilder {
    func nutritionView(delegate: NutritionDelegate, router: AnyRouter) -> some View {
        NutritionView(
            presenter: NutritionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            calendarHeader: { delegate, isCalendarExpanded in
                self.calendarHeaderView(
                    router: router,
                    delegate: delegate,
                    isCalendarExpanded: isCalendarExpanded
                )
            },
            mealHourHeader: { delegate in
                self.mealHourHeader(router: router, delegate: delegate)
            }
        )
    }
}

#Preview("No Meals ") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = NutritionDelegate()
    RouterView { router in
        builder.nutritionView(delegate: delegate, router: router)
    }
    
}

#Preview("With Meals") {
    let container = DevPreview.shared.container()
    
    let meals = MealLogModel.previewWeekMealsByDay.values.flatMap { $0 }
    let mealLogSyncEngine = CollectionSyncEngine<MealLogModel>(
        remote: MockRemoteCollectionService(collection: meals),
        managerKey: Keys.mealLogManagerKey,
        enableLocalPersistence: false,
        logger: nil
    )
    let draftMealPersistence = MockLocalDocumentPersistence<MealLogModel>()
    let mealLogManager = MealLogManager(draftMealLogPersistence: draftMealPersistence, mealLogSyncEngine: mealLogSyncEngine)
    container.register(MealLogManager.self, service: mealLogManager)
    
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = NutritionDelegate()
    return RouterView { router in
        builder.nutritionView(delegate: delegate, router: router)
    }
    .task {
        await mealLogManager.signIn(userId: UserModel.mock.userId)
    }
}
