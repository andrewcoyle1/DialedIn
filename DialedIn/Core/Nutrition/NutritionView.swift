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
            mealLogSection
            moreSection
            //            mealsSection
//
//            recipeLibraryButton
//
//            ingredientLibraryButton
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
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Image(systemName: "flame")
                            .font(.system(size: 16))
                        Text("\(Int(presenter.dailyTotals?.calories ?? 0))/\(Int(presenter.dailyTarget?.calories ?? 0))")
                            .lineLimit(1)
                            .font(.caption)
                    }
                    .frame(height: 16)
                    ProgressView(value: presenter.caloriePercentage)
                        .tint(.blue)
                }

                VStack(alignment: .leading) {
                    Text("P \(Int(presenter.dailyTotals?.proteinGrams ?? 0))/\(Int(presenter.dailyTarget?.proteinGrams ?? 0))")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(height: 16)

                    ProgressView(value: presenter.carbsPercentage)
                        .tint(.red)
                }

                VStack(alignment: .leading) {
                    Text("F \(Int(presenter.dailyTotals?.fatGrams ?? 0))/\(Int(presenter.dailyTarget?.fatGrams ?? 0))")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(height: 16)

                    ProgressView(value: presenter.fatPercentage)
                        .tint(.yellow)
                }
                
                VStack(alignment: .leading) {
                    Text("C \(Int(presenter.dailyTotals?.carbGrams ?? 0))/\(Int(presenter.dailyTarget?.carbGrams ?? 0))")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(height: 16)

                    ProgressView(value: presenter.carbsPercentage)
                        .tint(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .glassEffect()
            .padding(.horizontal)
        }
    }

    private var mealLogSection: some View {
        Section {
            ForEach(7...23) { hour in
                HStack {
                    Text("\(hour) AM")
                        .lineLimit(1)
                        .padding(8)
                        .frame(width: 70)
                        .background(.secondary.opacity(0.2), in: .capsule)
                    
                    Image(systemName: "plus")
                        .padding(8)
                        .background(.secondary.opacity(0.2), in: .circle)
                }
                .font(.caption)
                .padding(.bottom)
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        }
        .listSectionMargins(.top, 0)
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
    }
    
    private var moreSection: some View {
        Section {
            Group {
                CustomListCellView(sfSymbolName: "list.bullet", title: "Nutrition Overview")
                CustomListCellView(sfSymbolName: "slider.horizontal.3", title: "Customise Food Log")
            }
            .removeListRowFormatting()
        } header: {
            Text("More")
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
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
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
                Image(systemName: "plus")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
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
