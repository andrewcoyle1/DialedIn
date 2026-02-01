//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfileView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: ProfilePresenter

    var body: some View {
        List {
            if let user = presenter.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                profileHeaderSection
                    .listSectionMargins(.top, 0)

                generalSection
                nutritionSettingsSection
                trainingSettingsSection

                communityAndSupportSection

//                profilePhysicalMetricsSection
//                profileGoalsSection
//                profileNutritionPlanSection
//                profilePreferencesSection
//                profileMyTemplatesSection

                otherSection
            }
        }
        .navigationTitle("Profile")
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await presenter.getActiveGoal()

        }
    }

    private var profileHeaderSection: some View {
        Section {
            if let user = presenter.currentUser {
                HStack(spacing: 16) {
                    // Profile Image
                    CachedProfileImageView(
                        userId: user.userId,
                        imageUrl: user.profileImageUrl,
                        size: 60
                    )

                    // User Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text(presenter.fullName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        if let email = user.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                    }
                    Spacer()

                    Image(systemName: "chevron.right")
                }
                .tappableBackground()
                .anyButton(.highlight) {
                    presenter.onProfileEditPressed()
                }
            }
        }
    }

    private var generalSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "dollarsign",
                    title: "Subscription"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "app.connected.to.app.below.fill",
                    title: "Integrations"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "base.unit",
                    title: "Units"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "house",
                    title: "Dashboard"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "siri",
                    title: "Siri"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "bolt",
                    title: "Shortcuts"
                )
                .anyButton(.highlight) {

                }

            }
            .removeListRowFormatting()
        } header: {
            Text("General")
        }
    }

    private var nutritionSettingsSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "carrot",
                    title: "Food Log"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "flame",
                    title: "Expenditure"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "map",
                    title: "Strategy"
                )
                .anyButton(.highlight) {

                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Nutrition Settings")
        }
    }

    private var trainingSettingsSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "dumbbell",
                    title: "Gym Profiles"
                )
                .anyButton(.highlight) {
                    presenter.onGymProfilesPressed()
                }
                CustomListCellView(
                    sfSymbolName: "dumbbell",
                    title: "Exercises"
                )
                .anyButton(.highlight) {
                    presenter.onExerciseLibraryPressed()
                }
                CustomListCellView(
                    sfSymbolName: "dumbbell",
                    title: "Workout Settings"
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutSettingsPressed()
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Training Settings")
        }
    }

    private var communityAndSupportSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "book.closed",
                    title: "Knowledge Base"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "map",
                    title: "Roadmap"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "questionmark.circle",
                    title: "Support"
                )
                .anyButton(.highlight) {

                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Community & Support")
        }
    }

    private var profilePhysicalMetricsSection: some View {
        Section {
            if let user = presenter.currentUser {
                Button {
                    presenter.navToPhysicalStats()
                } label: {
                        VStack(spacing: 8) {
                            if let height = user.heightCentimeters {
                                MetricRow(
                                    label: "Height",
                                    value: presenter.formatHeight(height, unit: user.lengthUnitPreference ?? .centimeters)
                                )
                            }

                            if let weight = user.weightKilograms {
                                MetricRow(
                                    label: "Weight",
                                    value: presenter.formatWeight(weight, unit: user.weightUnitPreference ?? .kilograms)
                                )
                            }

                            if let height = user.heightCentimeters, let weight = user.weightKilograms {
                                let bmi = presenter.calculateBMI(heightCm: height, weightKg: weight)
                                MetricRow(
                                    label: "BMI",
                                    value: String(format: "%.1f", bmi)
                                )
                            }

                            if let frequency = user.exerciseFrequency {
                                MetricRow(
                                    label: "Exercise Frequency",
                                    value: presenter.formatExerciseFrequency(frequency)
                                )
                            }

                            if let activity = user.dailyActivityLevel {
                                MetricRow(
                                    label: "Activity Level",
                                    value: presenter.formatActivityLevel(activity)
                                )
                            }

                            if let cardio = user.cardioFitnessLevel {
                                MetricRow(
                                    label: "Cardio Fitness",
                                    value: presenter.formatCardioFitness(cardio)
                                )
                            }
                        }

                }
            }
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "figure.walk")
                    .font(.title3)
                    .foregroundStyle(.accent)
                    .frame(width: 28)

                Text("Physical Metrics")
                    .font(.headline)

                Spacer()
            }
        }

    }

    private var profileGoalsSection: some View {
        Section {
            if let goal = presenter.currentGoal,
               let user = presenter.currentUser {
                Button {
                    presenter.navToProfileGoals()
                } label: {

                    VStack(alignment: .leading, spacing: 8) {
                        Text(goal.objective.description.capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)

                        if let currentWeight = user.weightKilograms {
                            let unit = user.weightUnitPreference ?? .kilograms
                            HStack(spacing: 8) {
                                Text(presenter.formatWeight(currentWeight, unit: unit))
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(presenter.formatWeight(goal.targetWeightKg, unit: unit))
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }

                        if goal.weeklyChangeKg > 0 {
                            let unit = user.weightUnitPreference ?? .kilograms
                            Text("Weekly rate: \(presenter.formatWeight(goal.weeklyChangeKg, unit: unit))/week")
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
            } else if presenter.currentUser != nil {
                Button {
                    presenter.navToProfileGoals()
                } label: {
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
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .frame(width: 28)

                Text("Current Goal")
                    .font(.headline)

                Spacer()
            }
        }

    }

    private var profileNutritionPlanSection: some View {
        Section {
            if let plan = presenter.currentDietPlan {
                Button {
                    presenter.navToNutritionDetail()
                } label: {
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
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .frame(width: 28)

                Text("Nutrition Plan")
                    .font(.headline)

                Spacer()
            }
        }

    }

    private var profilePreferencesSection: some View {
        Section {
            Button {
                presenter.navToSettingsView()
            } label: {
                if let user = presenter.currentUser {
                    VStack(spacing: 8) {
                        MetricRow(
                            label: "Units",
                            value: presenter.formatUnitPreferences(
                                length: user.lengthUnitPreference,
                                weight: user.weightUnitPreference
                            )
                        )
                    }
                }
            }
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(.gray)
                    .frame(width: 28)

                Text("Preferences")
                    .font(.headline)

                Spacer()
            }
        }
    }

    private var profileMyTemplatesSection: some View {
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
            let templateIds = presenter.currentUser?.createdExerciseTemplateIds ?? []
            let count = templateIds.count

            Button {
                presenter.navToExerciseTemplateList()
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
            let templateIds = presenter.currentUser?.createdWorkoutTemplateIds ?? []
            let count = templateIds.count

            Button {
                presenter.navToWorkoutTemplateList()
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
            let templateIds = presenter.currentUser?.createdRecipeTemplateIds ?? []
            let count = templateIds.count

            Button {
                presenter.navToRecipeTemplateList()
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
            let templateIds = presenter.currentUser?.createdIngredientTemplateIds ?? []
            let count = templateIds.count

            Button {
                presenter.navToIngredientTemplateList()
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

    private var otherSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "book",
                    title: "Legal"
                )
                .anyButton(.highlight) {
                    presenter.onLegalPressed()
                }
                CustomListCellView(
                    sfSymbolName: "app.grid",
                    title: "App Icon"
                )
                .anyButton(.highlight) {
                    presenter.onAppIconPressed()
                }
                CustomListCellView(
                    sfSymbolName: "book",
                    title: "Tutorials"
                )
                .anyButton(.highlight) {
                    presenter.onTutorialPressed()
                }
                CustomListCellView(
                    sfSymbolName: "questionmark.circle",
                    title: "About"
                )
                .anyButton(.highlight) {
                    presenter.onAboutPressed()
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Other")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
            .badge(3)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}

extension CoreBuilder {
    func profileView(router: AnyRouter) -> some View {
        ProfileView(
            presenter: ProfilePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {

    func showProfileView() {
        router.showScreen(.sheet) { router in
            builder.profileView(router: router)
        }
    }

    func showProfileViewZoom(transitionId: String?, namespace: Namespace.ID) {
        router.showScreenWithZoomTransition(
            .sheet,
            transitionID: transitionId,
            namespace: namespace) { router in
                builder.profileView(router: router)
            }
    }
}

// MARK: - Previews
#Preview("User Has Profile") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}

#Preview("User No Profile") {
    let container = DevPreview.shared.container()

    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}
