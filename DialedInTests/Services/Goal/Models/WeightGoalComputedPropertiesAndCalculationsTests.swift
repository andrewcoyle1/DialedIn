//
//  WeightGoalComputedPropertiesAndCalculationsTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Testing
import Foundation

struct WeightGoalCompPropsAndCalcsTests {

    // MARK: - Computed Properties Tests
    
    @Test("Test Is Losing Property")
    func testIsLosingProperty() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        #expect(goal.isLosing == true)
    }
    
    @Test("Test Is Gaining Property")
    func testIsGainingProperty() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .gainWeight,
            startingWeightKg: 65.0,
            targetWeightKg: 70.0,
            weeklyChangeKg: 0.3
        )
        
        #expect(goal.isGaining == true)
    }
    
    @Test("Test Is Maintaining Property")
    func testIsMaintainingProperty() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .maintain,
            startingWeightKg: 70.0,
            targetWeightKg: 70.0,
            weeklyChangeKg: 0.0
        )
        
        #expect(goal.isMaintaining == true)
    }
    
    @Test("Test Total Weight Change")
    func testTotalWeightChange() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        #expect(goal.totalWeightChange == 7.0)
    }
    
    @Test("Test Estimated Weeks")
    func testEstimatedWeeks() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        // 7.0 kg / 0.5 kg per week = 14 weeks
        #expect(goal.estimatedWeeks == 14)
    }
    
    @Test("Test Estimated Weeks With Zero Weekly Change")
    func testEstimatedWeeksWithZeroWeeklyChange() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .maintain,
            startingWeightKg: 70.0,
            targetWeightKg: 70.0,
            weeklyChangeKg: 0.0
        )
        
        #expect(goal.estimatedWeeks == 0)
    }
    
    @Test("Test Estimated Months")
    func testEstimatedMonths() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        // 14 weeks / 4.33 = ~3.23, ceil = 4 months
        #expect(goal.estimatedMonths == 4)
    }
    
    // MARK: - Calculation Methods Tests
    
    @Test("Test Calculate Progress")
    func testCalculateProgress() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        // At 71.5 kg (halfway between 75 and 68)
        let progress = goal.calculateProgress(currentWeight: 71.5)
        #expect(progress == 0.5)
    }
    
    @Test("Test Calculate Progress At Start")
    func testCalculateProgressAtStart() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        let progress = goal.calculateProgress(currentWeight: 75.0)
        #expect(progress == 0.0)
    }
    
    @Test("Test Calculate Progress At Target")
    func testCalculateProgressAtTarget() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        let progress = goal.calculateProgress(currentWeight: 68.0)
        #expect(progress == 1.0)
    }
    
    @Test("Test Calculate Progress Returns Zero For Same Start And Target")
    func testCalculateProgressReturnsZeroForSameStartAndTarget() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .maintain,
            startingWeightKg: 70.0,
            targetWeightKg: 70.0,
            weeklyChangeKg: 0.0
        )
        
        let progress = goal.calculateProgress(currentWeight: 70.0)
        #expect(progress == 0.0)
    }
    
    @Test("Test Weight Changed")
    func testWeightChanged() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        let weightChanged = goal.weightChanged(currentWeight: 73.0)
        #expect(weightChanged == 2.0)
    }
    
    @Test("Test Weight Remaining")
    func testWeightRemaining() {
        let goal = WeightGoal(
            userId: String.random,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        let weightRemaining = goal.weightRemaining(currentWeight: 70.0)
        #expect(weightRemaining == 2.0)
    }
    
    // MARK: - Identifiable Tests
    
    @Test("Test WeightGoal Is Identifiable")
    func testWeightGoalIsIdentifiable() {
        let randomGoalId = String.random
        let randomUserId = String.random
        
        let goal = WeightGoal(
            goalId: randomGoalId,
            userId: randomUserId,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        #expect(goal.id == randomGoalId)
        #expect(goal.goalId == randomGoalId)
    }
    
    @Test("Test Default ID Generation")
    func testDefaultIdGeneration() {
        let randomUserId = String.random
        
        let goal1 = WeightGoal(
            userId: randomUserId,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        let goal2 = WeightGoal(
            userId: randomUserId,
            objective: .loseWeight,
            startingWeightKg: 75.0,
            targetWeightKg: 68.0,
            weeklyChangeKg: 0.5
        )
        
        // Both should have valid UUIDs, but different ones
        #expect(goal1.goalId != goal2.goalId)
        #expect(!goal1.goalId.isEmpty)
        #expect(!goal2.goalId.isEmpty)
    }
}
