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
import SwiftfulRouting

struct NutritionView<CalendarHeaderView: View>: View {

    @State var presenter: NutritionPresenter
    
    @ViewBuilder var calendarHeader: (CalendarHeaderDelegate) -> CalendarHeaderView

    @Namespace private var namespace
    
    var body: some View {
        List {
            dailySummarySection

            mealsSection

            addMealSection

            recipeLibraryButton

            ingredientLibraryButton
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Nutrition")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            toolbarContent
        }
        .toolbarRole(.browser)
        .task {
            await presenter.loadMeals()
        }
        .onChange(of: presenter.selectedDate) { _, _ in
            Task {
                await presenter.loadMeals()
            }
        }
        .safeAreaInset(edge: .top) {
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

    // MARK: - Daily Summary Section
    
    private var dailySummarySection: some View {
        Section {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    MacroStatCard(
                        title: "Calories",
                        current: presenter.dailyTotals?.calories ?? 0,
                        target: presenter.dailyTarget?.calories,
                        unit: "kcal"
                    )
                    
                    MacroStatCard(
                        title: "Protein",
                        current: presenter.dailyTotals?.proteinGrams ?? 0,
                        target: presenter.dailyTarget?.proteinGrams,
                        unit: "g"
                    )
                }
                
                HStack(spacing: 12) {
                    MacroStatCard(
                        title: "Carbs",
                        current: presenter.dailyTotals?.carbGrams ?? 0,
                        target: presenter.dailyTarget?.carbGrams,
                        unit: "g"
                    )
                    
                    MacroStatCard(
                        title: "Fat",
                        current: presenter.dailyTotals?.fatGrams ?? 0,
                        target: presenter.dailyTarget?.fatGrams,
                        unit: "g"
                    )
                }
            }
            .removeListRowFormatting()
            .padding(.vertical, 8)
        } header: {
            Text("Daily Summary - \(presenter.selectedDate.formattedDate)")
        }
    }
    
    // MARK: - Meals Section
    
    private var mealsSection: some View {
        ForEach(MealType.allCases, id: \.self) { mealType in
            let mealsForType = presenter.meals.filter { $0.mealType == mealType }
            
            Section {
                if mealsForType.isEmpty {
                    Button {
                        presenter.selectedMealType = mealType
                        presenter.onAddMealPressed(mealType: mealType)
                    } label: {
                        HStack {
                            Text("Add \(mealType.rawValue.capitalized)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.accent)
                        }
                    }
                } else {
                    ForEach(mealsForType) { meal in
                        Button {
                            presenter.navToMealDetail(meal: meal)
                        } label: {
                            MealLogRowView(meal: meal)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    await presenter.deleteMeal(meal)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                Text(mealType.rawValue.capitalized)
            }
        }
    }
    
    // MARK: - Add Meal Section
    
    private var addMealSection: some View {
        Section {
            Menu {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Button {
                        presenter.selectedMealType = mealType
                        presenter.onAddMealPressed(mealType: mealType)
                    } label: {
                        Label(mealType.rawValue.capitalized, systemImage: presenter.mealTypeIcon(mealType))
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.accent)
                    Text("Log Meal")
                        .font(.headline)
                    Spacer()
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            let avatarSize: CGFloat = 44

            Button {
                presenter.onProfilePressed()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let urlString = presenter.userImageUrl {
                            ImageLoaderView(urlString: urlString, clipShape: AnyShape(Circle()))
                        } else {
                            Circle()
                                .fill(.secondary.opacity(0.25))
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .frame(width: avatarSize, height: avatarSize)
                    .contentShape(Circle())
                }
            }
            .buttonStyle(.plain)
        }
        .sharedBackgroundVisibility(.hidden)

    }
    
    private var recipeLibraryButton: some View {
        Section {
            Button {
                presenter.onRecipeLibraryPressed()
            } label: {
                Text("Recipe Library")
            }
        } header: {
            Text("Recipe Library")
        }
    }
    
    private var ingredientLibraryButton: some View {
        Section {
            Button {
                presenter.onIngredientLibraryPressed()
            } label: {
                Text("Ingredient Library")
            }
        } header: {
            Text("Ingredient Library")
        }
    }
}

extension CoreBuilder {
    func nutritionView(router: AnyRouter) -> some View {
        NutritionView(
            presenter: NutritionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))) { delegate in
                self.calendarHeaderView(router: router, delegate: delegate)
            }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.nutritionView(router: router)
    }
    .previewEnvironment()
}
