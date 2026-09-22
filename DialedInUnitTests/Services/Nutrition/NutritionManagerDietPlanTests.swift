//
//  NutritionManagerDietPlanTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Testing
import Foundation
@testable import DialedIn

/// Turning four answers and a profile into seven days of targets.
///
/// `OnboardingDietPlanMathTests` covers the shape of the week — seven days, the floor, the varied
/// split totalling the same as a flat one, and that no figure comes out non-finite. This file
/// covers what that one does not: the exact macro split each diet produces, how the training
/// context is derived from the active program, and the bookkeeping fields the settings screens
/// read back.
@MainActor
struct NutritionManagerDietPlanTests {

    // MARK: - Fixtures

    /// A profile that produces round numbers: 80kg and 180cm at 36 puts Mifflin-St Jeor at 1750,
    /// and moderate activity with three-to-four sessions multiplies it by 1.6 to 2800. Every
    /// expectation below is arithmetic on that 2800, so a wrong split is a wrong number rather
    /// than a wrong-looking one.
    private func profile(
        weightKilograms: Double? = 80,
        heightCentimeters: Double? = 180,
        exerciseFrequency: ExerciseFrequency? = .threeToFour,
        dailyActivity: ActivityLevel? = .moderate,
        ageYears: Int? = 36
    ) -> UserModel {
        UserModel(
            userId: "user-1",
            submittedDateOfBirth: ageYears.map { years in
                // A day past the birthday, so the whole-year count cannot land a year short.
                let calendar = Calendar.current
                let birthday = calendar.date(byAdding: .year, value: -years, to: Date()) ?? Date()
                return calendar.date(byAdding: .day, value: -1, to: birthday) ?? birthday
            },
            submittedGender: .male,
            submittedHeightCentimeters: heightCentimeters,
            submittedWeightKilograms: weightKilograms,
            submittedExerciseFrequency: exerciseFrequency,
            submittedDailyActivityLevel: dailyActivity
        )
    }

    private func delegate(
        preferredDiet: PreferredDiet = .balanced,
        calorieFloor: CalorieFloor = .standard,
        calorieDistribution: CalorieDistribution = .even,
        proteinIntake: ProteinIntake = .moderate
    ) -> DietPlanDelegate {
        DietPlanDelegate(
            oldDelegate: ProteinIntakeDelegate(
                delegate: CalorieDistributionDelegate(
                    delegate: CalorieFloorDelegate(preferredDiet: preferredDiet, isFromSettings: false),
                    calorieFloor: calorieFloor
                ),
                calorieDistribution: calorieDistribution
            ),
            proteinIntake: proteinIntake
        )
    }

    /// A program of `trainingDays` days that carry exercises and `restDays` that do not. The
    /// absence of exercises is the only thing that marks a rest day.
    private func program(
        name: String = "Upper/Lower",
        trainingDays: Int,
        restDays: Int = 0
    ) -> TrainingProgram {
        let templates = (0..<(trainingDays + restDays)).map { index in
            WorkoutTemplateModel(
                id: "day-\(index)",
                authorId: "user-1",
                name: "Day \(index)",
                exercises: index < trainingDays
                    ? [WorkoutTemplateExercise(exercise: ExerciseModel.mock, setRestTimers: false)]
                    : []
            )
        }
        return TrainingProgram(
            id: "program-1",
            authorId: "user-1",
            name: name,
            icon: "flag",
            colour: "#FF0000",
            workoutTemplates: templates
        )
    }

    private func manager() -> NutritionManager {
        TestManagers.nutritionManager()
    }

    // MARK: - The macro split

    /// The exact numbers for the reference profile, so a change to any coefficient is visible
    /// rather than absorbed by a tolerance. 2800 calories, 2g of protein per kilogram, and the
    /// balanced diet's 30% fat share.
    @Test("Test The Balanced Split Produces The Expected Grams")
    func testTheBalancedSplitProducesTheExpectedGrams() throws {
        let plan = manager().computeDietPlan(user: profile(), delegate: delegate())

        let day = try #require(plan.days.first)
        #expect(abs(day.calories - 2800) < 0.01)
        #expect(abs(day.proteinGrams - 160) < 0.01)
        #expect(abs(day.fatGrams - 72) < 0.01)
        #expect(abs(day.carbGrams - 378) < 0.01)
    }

    /// The named percentage is applied to what protein leaves, not to the whole target: 30% fat on
    /// a 2800 calorie day with 640 calories of protein is 648 fat calories, which is 23% of the
    /// day rather than 30%. Worth pinning because the four diets are presented to the user as
    /// shares of the day, and this is the arithmetic behind that claim.
    @Test("Test The Fat Share Is Taken From What Protein Leaves")
    func testTheFatShareIsTakenFromWhatProteinLeaves() throws {
        let plan = manager().computeDietPlan(user: profile(), delegate: delegate(preferredDiet: .balanced))

        let day = try #require(plan.days.first)
        let afterProtein = day.calories - (day.proteinGrams * 4)
        #expect(abs((day.fatGrams * 9) - (afterProtein * 0.30)) < 5)
        // And the rest of that remainder is carbohydrate, to the gram.
        #expect(abs((day.carbGrams * 4) - (afterProtein * 0.70)) < 5)
    }

    /// The four diets have to be ordered by the thing they are named for, or the choice is
    /// decorative: keto the fewest carbohydrates, low fat the most, with the two middle options
    /// between them.
    @Test("Test Carbohydrates Fall As The Diet Restricts Them")
    func testCarbohydratesFallAsTheDietRestrictsThem() {
        let carbs = [PreferredDiet.keto, .lowCarb, .balanced, .lowFat].compactMap { diet in
            manager().computeDietPlan(
                user: profile(),
                delegate: delegate(preferredDiet: diet)
            ).days.first?.carbGrams
        }

        #expect(carbs.count == 4)
        #expect(carbs == carbs.sorted())
        #expect(Set(carbs).count == 4)
    }

    /// And fat runs the other way, since whatever protein leaves is divided between the two.
    @Test("Test Fat Rises As The Diet Restricts Carbohydrates")
    func testFatRisesAsTheDietRestrictsCarbohydrates() {
        let fats = [PreferredDiet.lowFat, .balanced, .lowCarb, .keto].compactMap { diet in
            manager().computeDietPlan(
                user: profile(),
                delegate: delegate(preferredDiet: diet)
            ).days.first?.fatGrams
        }

        #expect(fats.count == 4)
        #expect(fats == fats.sorted())
        #expect(Set(fats).count == 4)
    }

    /// Protein is grams per kilogram of bodyweight and does not depend on the diet chosen — the
    /// diet divides what is left, it does not take from protein.
    @Test("Test Protein Does Not Move With The Diet Chosen")
    func testProteinDoesNotMoveWithTheDietChosen() {
        let grams = PreferredDiet.allCases.map { diet in
            manager().computeDietPlan(user: profile(), delegate: delegate(preferredDiet: diet))
                .days.first?.proteinGrams
        }

        #expect(Set(grams.compactMap { $0 }).count == 1)
    }

    /// The four protein levels are 1.6, 2.0, 2.2 and 2.6 grams per kilogram. Pinned as grams for
    /// the reference 80kg profile so a changed coefficient is caught here rather than noticed as a
    /// shifted ring in the food log.
    @Test("Test Each Protein Level Is Its Own Grams Per Kilogram")
    func testEachProteinLevelIsItsOwnGramsPerKilogram() throws {
        let expected: [ProteinIntake: Double] = [.low: 128, .moderate: 160, .high: 176, .veryHigh: 208]

        for (intake, grams) in expected {
            let plan = manager().computeDietPlan(user: profile(), delegate: delegate(proteinIntake: intake))
            let actual = try #require(plan.days.first?.proteinGrams)

            #expect(abs(actual - grams) < 0.01)
        }
    }

    // MARK: - The training context

    /// A program is only a reason to vary the week if it contains training. A program of nothing
    /// but rest days is a program the user has not filled in yet, and varying around it would put
    /// three high days on a week with no sessions in it.
    @Test("Test A Program Of Rest Days Alone Leaves A Flat Week")
    func testAProgramOfRestDaysAloneLeavesAFlatWeek() {
        let plan = manager().computeDietPlan(
            user: profile(),
            delegate: delegate(calorieDistribution: .varied),
            trainingProgram: program(trainingDays: 0, restDays: 5)
        )

        #expect(Set(plan.days.map(\.calories)).count == 1)
    }

    /// One training day is enough: the split is between high and low days, not proportional to how
    /// many sessions the program holds.
    @Test("Test A Single Training Day Is Enough To Vary The Week")
    func testASingleTrainingDayIsEnoughToVaryTheWeek() {
        let plan = manager().computeDietPlan(
            user: profile(),
            delegate: delegate(calorieDistribution: .varied),
            trainingProgram: program(trainingDays: 1, restDays: 4)
        )

        #expect(Set(plan.days.map(\.calories)).count == 2)
    }

    /// An even distribution ignores the program entirely — the user asked for the same target
    /// every day and a program must not override that.
    @Test("Test An Even Distribution Ignores The Training Program")
    func testAnEvenDistributionIgnoresTheTrainingProgram() {
        let plan = manager().computeDietPlan(
            user: profile(),
            delegate: delegate(calorieDistribution: .even),
            trainingProgram: program(trainingDays: 5)
        )

        #expect(Set(plan.days.map(\.calories)).count == 1)
    }

    /// The floor binds the low days of a varied week too. A user whose estimate already sits at
    /// the floor cannot have 7.5% taken off four of their days.
    @Test("Test The Floor Holds On The Low Days Of A Varied Week")
    func testTheFloorHoldsOnTheLowDaysOfAVariedWeek() {
        let frail = profile(
            weightKilograms: 30,
            heightCentimeters: 120,
            exerciseFrequency: .never,
            dailyActivity: .sedentary,
            ageYears: 90
        )

        let plan = manager().computeDietPlan(
            user: frail,
            delegate: delegate(calorieDistribution: .varied),
            trainingProgram: program(trainingDays: 4)
        )

        #expect(plan.days.allSatisfy { $0.calories >= 1200 })
    }

    /// With a program, the plan records the program's name, so the settings screen can say what
    /// the week was built around.
    @Test("Test The Training Type Is The Program Name When There Is One")
    func testTheTrainingTypeIsTheProgramNameWhenThereIsOne() {
        let plan = manager().computeDietPlan(
            user: profile(),
            delegate: delegate(),
            trainingProgram: program(name: "Push Pull Legs", trainingDays: 3)
        )

        #expect(plan.trainingType == "Push Pull Legs")
    }

    /// Without one it falls back to a word for how often the user said they train. Each frequency
    /// has to map to its own word — two frequencies sharing one would make the caption meaningless
    /// for whichever user reads it.
    @Test("Test The Training Type Falls Back To The Stated Frequency")
    func testTheTrainingTypeFallsBackToTheStatedFrequency() {
        let expected: [ExerciseFrequency: String] = [
            .never: "none",
            .oneToTwo: "light",
            .threeToFour: "moderate",
            .fiveToSix: "frequent",
            .daily: "daily"
        ]

        for (frequency, description) in expected {
            let plan = manager().computeDietPlan(
                user: profile(exerciseFrequency: frequency),
                delegate: delegate()
            )

            #expect(plan.trainingType == description)
        }
    }

    /// A profile that never answered the frequency question reads as the middle option rather than
    /// as no training at all.
    @Test("Test A Missing Frequency Reads As Moderate Training")
    func testAMissingFrequencyReadsAsModerateTraining() {
        let plan = manager().computeDietPlan(user: profile(exerciseFrequency: nil), delegate: delegate())

        #expect(plan.trainingType == "moderate")
    }

    // MARK: - Bookkeeping

    /// The estimate stored on the plan is the one the screen prints above the week, and it is the
    /// unclamped figure — the floor moves the daily targets, not the estimate being reported.
    @Test("Test The Stored Estimate Is The Rounded Expenditure")
    func testTheStoredEstimateIsTheRoundedExpenditure() {
        let nutritionManager = manager()
        let user = profile()

        let plan = nutritionManager.computeDietPlan(user: user, delegate: delegate())

        #expect(abs(plan.tdeeEstimate - round(nutritionManager.estimateTDEE(user: user))) < 0.01)
    }

    /// The plan is identified by the user id, and `DietPlan.id` is `planId`. That is what makes a
    /// save land on the document the manager listens to: `saveDocument` writes to
    /// `document(model.id)`, and `CoreInteractor.logIn` signs the manager in under the account's
    /// uid. A fresh UUID here — as it used to be — wrote every plan to a document nothing was
    /// listening to, leaving `currentDietPlan` nil and the nutrition targets permanently blank.
    @Test("Test A Computed Plan Is Identified By The User")
    func testAComputedPlanIsIdentifiedByTheUser() throws {
        let nutritionManager = manager()
        let user = profile()

        let first = nutritionManager.computeDietPlan(user: user, delegate: delegate())
        let second = nutritionManager.computeDietPlan(user: user, delegate: delegate())

        let userId = try #require(user.userId)
        #expect(first.planId == userId)
        #expect(first.id == userId)
        // Recomputing replaces the plan rather than adding a second one beside it.
        #expect(second.planId == first.planId)
    }

    /// Onboarding can compute a plan before an account exists. There is no uid to key it by, so it
    /// falls back to a generated id — still addressable, still not listened to, which is why
    /// onboarding saves the plan after signing in.
    @Test("Test A Plan Computed Without A User Still Has An Identifier")
    func testAPlanComputedWithoutAUserStillHasAnIdentifier() {
        let plan = manager().computeDietPlan(user: nil, delegate: delegate())

        #expect(plan.planId.isEmpty == false)
        #expect(plan.id == plan.planId)
        #expect(plan.userId == nil)
    }

    /// The same answers and the same profile have to produce the same week. Two reads of a plan
    /// that disagreed would move the user's targets every time the settings screen recomputed.
    @Test("Test The Same Answers Produce The Same Week")
    func testTheSameAnswersProduceTheSameWeek() {
        let nutritionManager = manager()
        let user = profile()
        let answers = delegate(preferredDiet: .lowCarb, proteinIntake: .high)

        let first = nutritionManager.computeDietPlan(user: user, delegate: answers)
        let second = nutritionManager.computeDietPlan(user: user, delegate: answers)

        #expect(first.days == second.days)
        #expect(first.tdeeEstimate == second.tdeeEstimate)
    }

    /// The plan is stamped when it is built, so the settings screen can say how old the week's
    /// targets are.
    @Test("Test The Plan Is Stamped With The Time It Was Built")
    func testThePlanIsStampedWithTheTimeItWasBuilt() {
        let before = Date()

        let plan = manager().computeDietPlan(user: profile(), delegate: delegate())

        #expect(plan.createdAt >= before)
        #expect(plan.createdAt <= Date())
    }

    /// A plan computed for nobody — the settings rebuild before a profile has loaded — carries no
    /// author rather than an invented one.
    @Test("Test A Plan Built Without A Profile Has No Author")
    func testAPlanBuiltWithoutAProfileHasNoAuthor() {
        let plan = manager().computeDietPlan(user: nil, delegate: delegate())

        #expect(plan.userId == nil)
        #expect(plan.days.count == 7)
    }
}
