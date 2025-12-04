//
//  MealLogView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct MealLogView: View {

    @State var presenter: MealLogPresenter

    var delegate: MealLogDelegate

    var body: some View {
        Group {
            datePickerSection
            
            if presenter.isLoading {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            } else {
                dailySummarySection
                
                mealsSection
                
                addMealSection
            }
        }
        .task {
            await presenter.loadMeals()
        }
        .onChange(of: presenter.selectedDate) { _, _ in
            Task {
                await presenter.loadMeals()
            }
        }
    }
    
    // MARK: - Date Picker Section
    
    private var datePickerSection: some View {
        Section {
            HStack {
                Button {
                    presenter.selectedDate = presenter.selectedDate.addingDays(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: $presenter.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                
                Spacer()
                
                Button {
                    presenter.selectedDate = presenter.selectedDate.addingDays(1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.vertical, 8)
        }
        .listSectionSpacing(0)
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
            Text("Daily Summary")
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
}

#Preview {
    let delegate = MealLogDelegate(
        isShowingInspector: Binding.constant(false),
        selectedIngredientTemplate: Binding.constant(nil),
        selectedRecipeTemplate: Binding.constant(nil)
    )
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        List {
            builder.mealLogView(router: router, delegate: delegate)
        }
    }
    .previewEnvironment()
}
