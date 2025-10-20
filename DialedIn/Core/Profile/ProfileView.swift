//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(\.layoutMode) private var layoutMode
    @Environment(UserManager.self) private var userManager: UserManager
    @Environment(GoalManager.self) private var goalManager: GoalManager
    @Environment(NutritionManager.self) private var nutritionManager: NutritionManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    @State private var showNotifications: Bool = false
    @State private var showCreateProfileSheet: Bool = false
    @State private var showSetGoalSheet: Bool = false
    
    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack {
                    contentView
                }
            } else {
                contentView
            }
        }
    }
    
    private var contentView: some View {
        List {
            if let user = userManager.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                profileHeaderSection
                physicalMetricsSection
                goalsSection
                nutritionPlanSection
                preferencesSection
                myTemplatesSection
            } else {
                createProfileSection
            }
        }
        .navigationTitle("Profile")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.large)
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView, content: {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        })
        #endif
        .sheet(isPresented: $showCreateProfileSheet) {
            CreateAccountView()
                .presentationDetents([
                    .fraction(0.4)
                ])
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $showSetGoalSheet) {
            SetGoalFlowView()
        }
        .toolbar {
            toolbarContent
        }
        .task {
            if let userId = userManager.currentUser?.userId {
                try? await goalManager.getActiveGoal(userId: userId)
            }
        }
    }
}

// MARK: - Profile Header Section
extension ProfileView {
    
    private var profileHeaderSection: some View {
        Section {
            if let user = userManager.currentUser {
                NavigationLink {
                    ProfileEditView()
                } label: {
                    HStack(spacing: 16) {
                        // Profile Image
                        CachedProfileImageView(
                            userId: user.userId,
                            imageUrl: user.profileImageUrl,
                            size: 80
                        )
                        
                        // User Info
                        VStack(alignment: .leading, spacing: 6) {
                            Text(fullName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if let email = user.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let creationDate = user.creationDate {
                                Text("Member since \(creationDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .removeListRowFormatting()
    }
    
    private var fullName: String {
        guard let user = userManager.currentUser else { return "" }
        let first = user.firstName ?? ""
        let last = user.lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Physical Metrics Section
extension ProfileView {
    
    private var physicalMetricsSection: some View {
        Section {
            if let user = userManager.currentUser {
                NavigationLink {
                    ProfilePhysicalStatsView()
                } label: {
                    ProfileSectionCard(
                        icon: "figure.walk",
                        title: "Physical Metrics"
                    ) {
                        VStack(spacing: 8) {
                            if let height = user.heightCentimeters {
                                MetricRow(
                                    label: "Height",
                                    value: formatHeight(height, unit: user.lengthUnitPreference ?? .centimeters)
                                )
                            }
                            
                            if let weight = user.weightKilograms {
                                MetricRow(
                                    label: "Weight",
                                    value: formatWeight(weight, unit: user.weightUnitPreference ?? .kilograms)
                                )
                            }
                            
                            if let height = user.heightCentimeters, let weight = user.weightKilograms {
                                let bmi = calculateBMI(heightCm: height, weightKg: weight)
                                MetricRow(
                                    label: "BMI",
                                    value: String(format: "%.1f", bmi)
                                )
                            }
                            
                            if let frequency = user.exerciseFrequency {
                                MetricRow(
                                    label: "Exercise Frequency",
                                    value: formatExerciseFrequency(frequency)
                                )
                            }
                            
                            if let activity = user.dailyActivityLevel {
                                MetricRow(
                                    label: "Activity Level",
                                    value: formatActivityLevel(activity)
                                )
                            }
                            
                            if let cardio = user.cardioFitnessLevel {
                                MetricRow(
                                    label: "Cardio Fitness",
                                    value: formatCardioFitness(cardio)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Goals Section
extension ProfileView {
    
    private var goalsSection: some View {
        Section {
            if let goal = goalManager.currentGoal,
               let user = userManager.currentUser {
                NavigationLink {
                    ProfileGoalsDetailView()
                } label: {
                    ProfileSectionCard(
                        icon: "target",
                        iconColor: .green,
                        title: "Current Goal"
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(goal.objective.capitalized)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if let currentWeight = user.weightKilograms {
                                let unit = user.weightUnitPreference ?? .kilograms
                                HStack(spacing: 8) {
                                    Text(formatWeight(currentWeight, unit: unit))
                                    Image(systemName: "arrow.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(formatWeight(goal.targetWeightKg, unit: unit))
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                            
                            if goal.weeklyChangeKg > 0 {
                                let unit = user.weightUnitPreference ?? .kilograms
                                Text("Weekly rate: \(formatWeight(goal.weeklyChangeKg, unit: unit))/week")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            
                            // Progress indicator
                            if let currentWeight = user.weightKilograms, goal.weeklyChangeKg > 0 {
                                let progress = goal.calculateProgress(currentWeight: currentWeight)
                                let weeks = Int(ceil(abs(goal.targetWeightKg - currentWeight) / goal.weeklyChangeKg))
                                
                                Divider()
                                
                                HStack {
                                    Text("Progress: \(Int(progress * 100))%")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("~\(weeks) weeks")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } else if userManager.currentUser != nil {
                Button {
                    showSetGoalSheet = true
                } label: {
                    ProfileSectionCard(
                        icon: "target",
                        iconColor: .green,
                        title: "Set a Goal"
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Define your weight goal to start tracking progress")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Get Started")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Nutrition Plan Section
extension ProfileView {
    
    private var nutritionPlanSection: some View {
        Section {
            if let plan = nutritionManager.currentDietPlan {
                NavigationLink {
                    ProfileNutritionDetailView()
                } label: {
                    ProfileSectionCard(
                        icon: "fork.knife",
                        iconColor: .orange,
                        title: "Nutrition Plan"
                    ) {
                        VStack(spacing: 8) {
                            MetricRow(
                                label: "TDEE Estimate",
                                value: "\(Int(plan.tdeeEstimate)) kcal/day"
                            )
                            
                            MetricRow(
                                label: "Diet Type",
                                value: plan.preferredDiet.capitalized
                            )
                            
                            MetricRow(
                                label: "Training Focus",
                                value: plan.trainingType.replacingOccurrences(of: "_", with: " ").capitalized
                            )
                            
                            // Average daily calories
                            let avgCalories = plan.days.reduce(0.0) { $0 + $1.calories } / Double(plan.days.count)
                            MetricRow(
                                label: "Avg Daily Calories",
                                value: "\(Int(avgCalories)) kcal"
                            )
                            
                            // Average macros
                            let avgProtein = plan.days.reduce(0.0) { $0 + $1.proteinGrams } / Double(plan.days.count)
                            let avgCarbs = plan.days.reduce(0.0) { $0 + $1.carbGrams } / Double(plan.days.count)
                            let avgFat = plan.days.reduce(0.0) { $0 + $1.fatGrams } / Double(plan.days.count)
                            
                            HStack(spacing: 16) {
                                VStack(spacing: 2) {
                                    Text("\(Int(avgProtein))g")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text("Protein")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack(spacing: 2) {
                                    Text("\(Int(avgCarbs))g")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text("Carbs")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack(spacing: 2) {
                                    Text("\(Int(avgFat))g")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text("Fat")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preferences Section
extension ProfileView {
    
    private var preferencesSection: some View {
        Section {
            NavigationLink {
                SettingsView()
            } label: {
                ProfileSectionCard(
                    icon: "gearshape",
                    iconColor: .gray,
                    title: "Preferences"
                ) {
                    if let user = userManager.currentUser {
                        VStack(spacing: 8) {
                            MetricRow(
                                label: "Units",
                                value: formatUnitPreferences(
                                    length: user.lengthUnitPreference,
                                    weight: user.weightUnitPreference
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - My Templates Section
extension ProfileView {
    
    private var myTemplatesSection: some View {
        Section {
            exerciseTemplateSection
            workoutTemplateSection
            recipeTemplateSection
            ingredientTemplateSection
        } header: {
            Text("My Templates")
        }
    }
    
    private var exerciseTemplateSection: some View {
        Group {
            let templateIds = userManager.currentUser?.createdExerciseTemplateIds ?? []
            let count = templateIds.count
            
            NavigationLink {
                ExerciseTemplateListView(templateIds: templateIds)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exercise Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var workoutTemplateSection: some View {
        Group {
            let templateIds = userManager.currentUser?.createdWorkoutTemplateIds ?? []
            let count = templateIds.count
            
            NavigationLink {
                WorkoutTemplateListView(templateIds: templateIds)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workout Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var recipeTemplateSection: some View {
        Group {
            let templateIds = userManager.currentUser?.createdRecipeTemplateIds ?? []
            let count = templateIds.count
            
            NavigationLink {
                RecipeTemplateListView(templateIds: templateIds)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recipe Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var ingredientTemplateSection: some View {
        Group {
            let templateIds = userManager.currentUser?.createdIngredientTemplateIds ?? []
            let count = templateIds.count
            
            NavigationLink {
                IngredientTemplateListView(templateIds: templateIds)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ingredient Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Create Profile Section
extension ProfileView {
    
    private var createProfileSection: some View {
        Section {
            Button {
                showCreateProfileSheet = true
            } label: {
                CustomListCellView(
                    imageName: nil,
                    title: "Create your profile",
                    subtitle: "Tap to get started",
                    isSelected: true,
                    iconName: "person.circle",
                    iconSize: CGFloat(32)
                )
            }
            .removeListRowFormatting()
        } header: {
            Text("Profile")
        }
    }
}

// MARK: - Toolbar
extension ProfileView {
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gear")
            }
        }
    }
    
    private func onNotificationsPressed() {
        showNotifications = true
    }
}

// MARK: - Helper Functions
extension ProfileView {
    
    private func formatHeight(_ heightCm: Double, unit: LengthUnitPreference) -> String {
        switch unit {
        case .centimeters:
            return String(format: "%.0f cm", heightCm)
        case .inches:
            let totalInches = heightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        }
    }
    
    private func formatWeight(_ weightKg: Double, unit: WeightUnitPreference) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
    
    private func calculateBMI(heightCm: Double, weightKg: Double) -> Double {
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }
    
    private func formatExerciseFrequency(_ frequency: ProfileExerciseFrequency) -> String {
        switch frequency {
        case .never: return "Never"
        case .oneToTwo: return "1-2 times/week"
        case .threeToFour: return "3-4 times/week"
        case .fiveToSix: return "5-6 times/week"
        case .daily: return "Daily"
        }
    }
    
    private func formatActivityLevel(_ level: ProfileDailyActivityLevel) -> String {
        switch level {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        }
    }
    
    private func formatCardioFitness(_ level: ProfileCardioFitnessLevel) -> String {
        switch level {
        case .beginner: return "Beginner"
        case .novice: return "Novice"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .elite: return "Elite"
        }
    }
    
    private func formatUnitPreferences(length: LengthUnitPreference?, weight: WeightUnitPreference?) -> String {
        let lengthStr = length == .centimeters ? "Metric" : "Imperial"
        let weightStr = weight == .kilograms ? "Metric" : "Imperial"
        
        if lengthStr == weightStr {
            return lengthStr
        } else {
            return "Mixed"
        }
    }
    
}

// MARK: - Previews
#Preview("User Has Profile") {
    let goalManager = GoalManager(services: MockGoalServices())
    goalManager.setCurrentGoalForTesting(WeightGoal.mock(
        objective: "lose weight",
        startingWeightKg: 63.0,
        targetWeightKg: 55.0,
        weeklyChangeKg: 0.5
    ))
    
    return ProfileView()
        .environment(
            UserManager(
                services: MockUserServices(
                    user: UserModel(
                        userId: "mockUser",
                        email: "user@example.com",
                        isAnonymous: false,
                        firstName: "Alice",
                        lastName: "Cooper",
                        dateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15)),
                        gender: .female,
                        heightCentimeters: 165,
                        weightKilograms: 60,
                        exerciseFrequency: .threeToFour,
                        dailyActivityLevel: .moderate,
                        cardioFitnessLevel: .intermediate,
                        lengthUnitPreference: .centimeters,
                        weightUnitPreference: .kilograms,
                        profileImageUrl: nil,
                        creationDate: Date(),
                        didCompleteOnboarding: true
                    )
                )
            )
        )
        .environment(goalManager)
        .previewEnvironment()
}

#Preview("User No Profile") {
    ProfileView()
        .environment(
            UserManager(
                services: MockUserServices(
                    user: UserModel(
                        userId: UUID().uuidString,
                        email: "user@example.com",
                        isAnonymous: false,
                        creationDate: Date(),
                        didCompleteOnboarding: false
                    )
                )
            )
        )
        .previewEnvironment()
}
