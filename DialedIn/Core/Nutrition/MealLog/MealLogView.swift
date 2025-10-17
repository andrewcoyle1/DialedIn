//
//  MealLogView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct MealLogView: View {
    
    @Environment(MealLogManager.self) private var mealLogManager
    @Environment(UserManager.self) private var userManager
    @Environment(NutritionManager.self) private var nutritionManager
    
    @Binding var isShowingInspector: Bool
    @Binding var selectedIngredientTemplate: IngredientTemplateModel?
    @Binding var selectedRecipeTemplate: RecipeTemplateModel?
    
    @State private var selectedDate: Date = Date()
    @State private var meals: [MealLogModel] = []
    @State private var dailyTotals: DailyMacroTarget?
    @State private var dailyTarget: DailyMacroTarget?
    @State private var isLoading: Bool = false
    @State private var showAddMealSheet: Bool = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var showAlert: AnyAppAlert?
    
    @State private var navigateToMealDetailView: Bool = false
    @State private var selectedMeal: MealLogModel?
    
    private var dayKey: String {
        selectedDate.dayKey
    }
    
    var body: some View {
        Group {
            datePickerSection
            
            if isLoading {
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
        .navigationDestination(isPresented: $navigateToMealDetailView) {
            if let selectedMeal {
                MealDetailView(meal: selectedMeal)
            } else {
                EmptyView()
            }
        }
        .task {
            await loadMeals()
        }
        .onChange(of: selectedDate) { _, _ in
            Task {
                await loadMeals()
            }
        }
        .sheet(isPresented: $showAddMealSheet) {
            AddMealSheet(
                selectedDate: selectedDate,
                mealType: selectedMealType,
                onSave: { meal in
                    Task {
                        await saveMeal(meal)
                    }
                }
            )
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    // MARK: - Date Picker Section
    
    private var datePickerSection: some View {
        Section {
            HStack {
                Button {
                    selectedDate = selectedDate.addingDays(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                
                Spacer()
                
                Button {
                    selectedDate = selectedDate.addingDays(1)
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
                        current: dailyTotals?.calories ?? 0,
                        target: dailyTarget?.calories,
                        unit: "kcal"
                    )
                    
                    MacroStatCard(
                        title: "Protein",
                        current: dailyTotals?.proteinGrams ?? 0,
                        target: dailyTarget?.proteinGrams,
                        unit: "g"
                    )
                }
                
                HStack(spacing: 12) {
                    MacroStatCard(
                        title: "Carbs",
                        current: dailyTotals?.carbGrams ?? 0,
                        target: dailyTarget?.carbGrams,
                        unit: "g"
                    )
                    
                    MacroStatCard(
                        title: "Fat",
                        current: dailyTotals?.fatGrams ?? 0,
                        target: dailyTarget?.fatGrams,
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
            let mealsForType = meals.filter { $0.mealType == mealType }
            
            Section {
                if mealsForType.isEmpty {
                    Button {
                        selectedMealType = mealType
                        showAddMealSheet = true
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
                        MealLogRowView(meal: meal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedMeal = meal
                                navigateToMealDetailView = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await deleteMeal(meal)
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
                        selectedMealType = mealType
                        showAddMealSheet = true
                    } label: {
                        Label(mealType.rawValue.capitalized, systemImage: mealTypeIcon(mealType))
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
    
    // MARK: - Helper Functions
    
    private func mealTypeIcon(_ mealType: MealType) -> String {
        switch mealType {
        case .breakfast:
            return "sunrise.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "moon.stars.fill"
        case .snack:
            return "fork.knife"
        }
    }
    
    private func loadMeals() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            meals = try mealLogManager.getMeals(for: dayKey).sorted(by: { $0.date < $1.date })
            dailyTotals = try mealLogManager.getDailyTotals(dayKey: dayKey)
            
            // Load target for the day (if diet plan exists)
            if let user = userManager.currentUser {
                dailyTarget = try await nutritionManager.getDailyTarget(for: selectedDate, userId: user.userId)
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func saveMeal(_ meal: MealLogModel) async {
        do {
            try await mealLogManager.addMeal(meal)
            await loadMeals()
            showAddMealSheet = false
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func deleteMeal(_ meal: MealLogModel) async {
        do {
            try await mealLogManager.deleteMealAndSync(
                id: meal.mealId,
                dayKey: meal.dayKey,
                authorId: meal.authorId
            )
            await loadMeals()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            MealLogView(
                isShowingInspector: Binding.constant(false),
                selectedIngredientTemplate: Binding.constant(nil),
                selectedRecipeTemplate: Binding.constant(nil)
            )
        }
    }
    .previewEnvironment()
}
