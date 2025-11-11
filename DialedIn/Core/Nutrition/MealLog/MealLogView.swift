//
//  MealLogView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct MealLogView: View {

    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: MealLogViewModel

    @Binding var path: [TabBarPathOption]

    @Binding var isShowingInspector: Bool
    @Binding var selectedIngredientTemplate: IngredientTemplateModel?
    @Binding var selectedRecipeTemplate: RecipeTemplateModel?
    
    var body: some View {
        Group {
            datePickerSection
            
            if viewModel.isLoading {
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
            await viewModel.loadMeals()
        }
        .onChange(of: viewModel.selectedDate) { _, _ in
            Task {
                await viewModel.loadMeals()
            }
        }
        .sheet(isPresented: $viewModel.showAddMealSheet) {
            builder.addMealSheet(selectedDate: viewModel.selectedDate, mealType: viewModel.selectedMealType, onSave: { meal in
                Task {
                    await viewModel.saveMeal(meal)
                }
            }, path: $path)
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    // MARK: - Date Picker Section
    
    private var datePickerSection: some View {
        Section {
            HStack {
                Button {
                    viewModel.selectedDate = viewModel.selectedDate.addingDays(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                
                Spacer()
                
                Button {
                    viewModel.selectedDate = viewModel.selectedDate.addingDays(1)
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
                        current: viewModel.dailyTotals?.calories ?? 0,
                        target: viewModel.dailyTarget?.calories,
                        unit: "kcal"
                    )
                    
                    MacroStatCard(
                        title: "Protein",
                        current: viewModel.dailyTotals?.proteinGrams ?? 0,
                        target: viewModel.dailyTarget?.proteinGrams,
                        unit: "g"
                    )
                }
                
                HStack(spacing: 12) {
                    MacroStatCard(
                        title: "Carbs",
                        current: viewModel.dailyTotals?.carbGrams ?? 0,
                        target: viewModel.dailyTarget?.carbGrams,
                        unit: "g"
                    )
                    
                    MacroStatCard(
                        title: "Fat",
                        current: viewModel.dailyTotals?.fatGrams ?? 0,
                        target: viewModel.dailyTarget?.fatGrams,
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
            let mealsForType = viewModel.meals.filter { $0.mealType == mealType }
            
            Section {
                if mealsForType.isEmpty {
                    Button {
                        viewModel.selectedMealType = mealType
                        viewModel.showAddMealSheet = true
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
                            viewModel.navToMealDetail(path: $path, meal: meal)
                        } label: {
                            MealLogRowView(meal: meal)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteMeal(meal)
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
                        viewModel.selectedMealType = mealType
                        viewModel.showAddMealSheet = true
                    } label: {
                        Label(mealType.rawValue.capitalized, systemImage: viewModel.mealTypeIcon(mealType))
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
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        List {
            builder.mealLogView(path: $path, isShowingInspector: Binding.constant(false), selectedIngredientTemplate: Binding.constant(nil), selectedRecipeTemplate: Binding.constant(nil))
        }
    }
    .previewEnvironment()
}
