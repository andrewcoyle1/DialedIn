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
    @ViewBuilder var calendarHeader: (CalendarHeaderDelegate) -> CalendarHeaderView
    @ViewBuilder var mealHourHeader: (MealHourHeaderDelegate) -> MealHeader
    @Namespace private var namespace
        
    var body: some View {
        List {
            ringsSection
            mealLogSection
            moreSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Nutrition")
        .toolbarTitleDisplayMode(.inlineLarge)
        .onAppear { presenter.onViewAppear(delegate: delegate) }
        .onDisappear { presenter.onViewDisappear(delegate: delegate) }
        .toolbar {
            toolbarContent
        }
        .toolbarRole(.browser)
        .safeAreaInset(edge: .top) {
            topSafeAreaSection
        }
    }
    
    private var topSafeAreaSection: some View {
        VStack {
            calendarHeader(
                CalendarHeaderDelegate(
                    onDatePressed: { date in
                        presenter.selectedDate = date.startOfDay
                    },
                    getForDate: { date in
                        presenter.getMealCountForDate(
                            date: date
                        )
                    }
                )
            )
        }
    }
    
    private var ringsSection: some View {
        Section {
            let ringSize: CGFloat = 75
            return MacroHeader(
                caloriePercentage: presenter.caloriePercentage,
                fatPercentage: presenter.fatPercentage,
                proteinPercentage: presenter.proteinPercentage,
                carbsPercentage: presenter.carbsPercentage
            )
            .listRowInsets(.horizontal, 0)
        }
        .listSectionMargins(.top, 0)
    }
    
    private var mealLogSection: some View {
        ForEach(presenter.workingHours, id: \.self) { hour in
            Section {
                let hourssMeals = presenter.meals(inHour: hour)
                let delegate = MealHourHeaderDelegate(hour: hour, meals: hourssMeals)
                mealHourHeader(delegate)
                    .removeListRowFormatting()
                    .padding(.horizontal)
                ForEach(hourssMeals) { meal in
                    ForEach(meal.items) { item in
                        mealItemRow(item, meal: meal)
                    }
                }
            }
            .listSectionMargins(.all, 0)
            .listSectionSpacing(0)
        }
        .listRowSeparator(.hidden)
    }

    private func mealItemRow(_ item: MealItemModel, meal: MealLogModel) -> some View {
        MealItemRowView(mealLogModel: meal, item: item)
            .removeListRowFormatting()
            .padding(.horizontal)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    presenter.deleteMealItem(item, from: meal)
                }
            }
    }
    
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
                presenter.onTimelineActionsPressed()
            } label: {
                Image(systemName: "line.3.horizontal")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            let avatarSize: CGFloat = 44
            
            Button {
                presenter.onProfilePressed()
            } label: {
                ZStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 24))
                    if let urlString = presenter.userImageUrl {
                        ImageLoaderView(urlString: urlString, clipShape: AnyShape(Circle()))
                            .frame(width: avatarSize, height: avatarSize)
                            .contentShape(Circle())
                    }
                }
            }
        }
        .sharedBackgroundVisibility(.hidden)
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
            calendarHeader: { delegate in
                self.calendarHeaderView(router: router, delegate: delegate)
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
