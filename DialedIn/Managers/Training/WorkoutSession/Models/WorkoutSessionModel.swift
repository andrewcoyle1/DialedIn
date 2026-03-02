//
//  WorkoutSession.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation

struct WorkoutSessionModel: DataSyncModelProtocol, Equatable {
    let id: String
    let authorId: String
    var name: String
    let workoutTemplateId: String?
    let scheduledWorkoutId: String?
    let trainingPlanId: String?
    let programId: String?
    let dayPlanId: String?
    let dateCreated: Date
    private(set) var dateModified: Date
    private(set) var endedAt: Date?
    var notes: String?
    var exercises: [WorkoutExerciseModel]
    var deletedAt: Date?

    init(
        id: String = UUID().uuidString,
        authorId: String,
        name: String,
        workoutTemplateId: String? = nil,
        scheduledWorkoutId: String? = nil,
        trainingPlanId: String? = nil,
        programId: String? = nil,
        dayPlanId: String? = nil,
        dateCreated: Date,
        dateModified: Date? = nil,
        endedAt: Date? = nil,
        notes: String? = nil,
        exercises: [WorkoutExerciseModel],
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.workoutTemplateId = workoutTemplateId
        self.scheduledWorkoutId = scheduledWorkoutId
        self.trainingPlanId = trainingPlanId
        self.programId = programId
        self.dayPlanId = dayPlanId
        self.dateCreated = dateCreated
        self.dateModified = dateModified ?? dateCreated
        self.endedAt = endedAt
        self.notes = notes
        self.exercises = exercises
        self.deletedAt = deletedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name = "name"
        case workoutTemplateId = "workout_template_id"
        case scheduledWorkoutId = "scheduled_workout_id"
        case trainingPlanId = "training_plan_id"
        case programId = "program_id"
        case dayPlanId = "day_plan_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case endedAt = "ended_at"
        case notes
        case exercises
        case deletedAt = "deleted_at"
    }

    @MainActor
    // swiftlint:disable:next function_body_length
    init(
        id: String = UUID().uuidString,
        authorId: String,
        template: WorkoutTemplateModel,
        notes: String? = nil,
        scheduledWorkoutId: String? = nil,
        trainingPlanId: String? = nil,
        programId: String? = nil,
        dayPlanId: String? = nil,
        previousWorkoutSession: WorkoutSessionModel? = nil,
        gymProfile: GymProfileModel? = nil,
        unitPreferences: [String: ExerciseUnitPreference]? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.name = template.name
        self.workoutTemplateId = template.id
        self.scheduledWorkoutId = scheduledWorkoutId
        self.trainingPlanId = trainingPlanId
        self.programId = programId
        self.dayPlanId = dayPlanId
        self.dateCreated = .now
        self.dateModified = .now
        self.endedAt = nil
        self.notes = notes
        self.deletedAt = nil
        self.exercises = template.exercises.enumerated().map { (idx, exerciseModel) in
            let mode = WorkoutSessionModel.trackingMode(for: exerciseModel.exercise)
            let targetCount = exerciseModel.setTargets.count
                        
            // Find matching exercise in previous workout session
            let previousExercise = previousWorkoutSession?.exercises.first(where: { $0.templateId == exerciseModel.exercise.id })
            let previousSets = previousExercise?.sets
                        
            // Estimate working weight and reps from previous workout
            let (estimatedWeight, estimatedReps) = WorkoutSessionModel.estimateWorkingWeightFromPrevious(previousSets: previousSets)
            
            // Create working sets (SetTargets) and populate with previous values if available
            var workingSets = WorkoutSessionModel.defaultSets(
                trackingMode: mode,
                authorId: authorId,
                targetCount: max(targetCount, 1)
            )
            
            // Populate working sets with values from previous workout (smart progression)
            if let prevSets = previousSets {
                // Match working sets with previous workout sets by index (skip warmup sets)
                let previousWorkingSets = prevSets.filter { !$0.isWarmup }
                
                for index in workingSets.indices {
                    if index < previousWorkingSets.count {
                        let prevSet = previousWorkingSets[index]
                        var weightKg = prevSet.weightKg ?? workingSets[index].weightKg
                        
                        // Round weight to equipment increments if available, using preferred unit
                        if let weight = weightKg {
                            let unitPref = unitPreferences?[exerciseModel.exercise.id]
                            let preferredUnit = unitPref?.weightUnit
                            
                            // Try equipment rounding first (only applies to pin-loaded/cable machines)
                            let roundedByEquipment = WorkoutSessionModel.roundWeightToEquipmentIncrement(
                                weightKg: weight,
                                exercise: exerciseModel.exercise,
                                gymProfile: gymProfile,
                                preferredWeightUnit: preferredUnit
                            )
                            
                            // If equipment rounding didn't change the weight (free weights), apply unit rounding
                            if roundedByEquipment == weight, let preferredUnit = preferredUnit {
                                weightKg = WorkoutSessionModel.roundWeightToPreferredUnit(
                                    weightKg: roundedByEquipment,
                                    preferredUnit: preferredUnit
                                )
                            } else {
                                weightKg = roundedByEquipment
                            }
                        }
                        
                        workingSets[index] = WorkoutSetModel(
                            id: workingSets[index].id,
                            authorId: authorId,
                            index: workingSets[index].index,
                            reps: prevSet.reps ?? workingSets[index].reps,
                            weightKg: weightKg,
                            durationSec: prevSet.durationSec ?? workingSets[index].durationSec,
                            distanceMeters: prevSet.distanceMeters ?? workingSets[index].distanceMeters,
                            rpe: workingSets[index].rpe,
                            isWarmup: false,
                            completedAt: nil,
                            dateCreated: .now
                        )
                    }
                }
            }
            
            // Use the first working set's weight/reps for warmup calculation, or fall back to estimated values
            let firstWorkingSet = workingSets.first
            let workingWeightKg = firstWorkingSet?.weightKg ?? estimatedWeight
            let workingReps = firstWorkingSet?.reps ?? estimatedReps
                        
            // Generate warmup sets using working weight/reps
            let warmupSets = WorkoutSessionModel.generateWarmupSets(
                trackingMode: mode,
                authorId: authorId,
                workingWeightKg: workingWeightKg,
                workingReps: workingReps,
                setTargets: exerciseModel.setTargets,
                exercise: exerciseModel.exercise,
                gymProfile: gymProfile,
                unitPreferences: unitPreferences
            )
            
            // Prepend warmup sets to working sets
            let allSets = warmupSets + workingSets
            
            // Re-index all sets: warmup sets first, then working sets
            let reindexedSets = allSets.enumerated().map { index, set in
                WorkoutSetModel(
                    id: set.id,
                    authorId: set.authorId,
                    index: index + 1,
                    reps: set.reps,
                    weightKg: set.weightKg,
                    durationSec: set.durationSec,
                    distanceMeters: set.distanceMeters,
                    rpe: set.rpe,
                    isWarmup: set.isWarmup,
                    completedAt: set.completedAt,
                    dateCreated: set.dateCreated
                )
            }
            
            let imageName = Constants.exerciseImageName(for: exerciseModel.exercise.name)
            return WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: authorId,
                templateId: exerciseModel.exercise.id,
                name: exerciseModel.exercise.name,
                trackingMode: mode,
                index: idx + 1,
                notes: nil,
                imageName: imageName,
                sets: reindexedSets,
                setTargets: exerciseModel.setTargets,
                chosenResistanceEquipment: exerciseModel.exercise.resistanceEquipment,
                chosenSupportEquipment: exerciseModel.exercise.supportEquipment
            )
        }
    }

    static func trackingMode(for exercise: ExerciseModel) -> TrackingMode {
        let metrics = Set(exercise.trackableMetrics)
        let weightMetrics: Set<TrackableExerciseMetric> = [
            .weight,
            .weightPerSide,
            .weightPerSidePersistent,
            .weightPerSideAssistance
        ]
        let timeMetrics: Set<TrackableExerciseMetric> = [.duration, .durationPerSide]
        let distanceMetrics: Set<TrackableExerciseMetric> = [.distanceShort, .distanceShortPerSide, .distanceLong]

        if !metrics.isDisjoint(with: weightMetrics) {
            return .weightReps
        }
        if !metrics.isDisjoint(with: distanceMetrics) {
            return .distanceTime
        }
        if !metrics.isDisjoint(with: timeMetrics) {
            return .timeOnly
        }
        return .repsOnly
    }

    // Mutating methods for workout tracker
    mutating func updateExercises(_ exercises: [WorkoutExerciseModel]) {
        self.exercises = exercises
        self.dateModified = Date()
    }
    
    mutating func endSession(at date: Date) {
        self.endedAt = date
        self.dateModified = date
    }
    
    /// Estimates working weight and reps from previous workout sets
    /// Returns the weight and reps from the first non-warmup set, if available
    static func estimateWorkingWeightFromPrevious(
        previousSets: [WorkoutSetModel]?
    ) -> (weightKg: Double?, reps: Int?) {
        guard let previousSets = previousSets else {
            return (nil, nil)
        }
                
        // Find the first non-warmup set
        if let firstWorkingSet = previousSets.first(where: { !$0.isWarmup }) {
            return (firstWorkingSet.weightKg, firstWorkingSet.reps)
        }
        
        // If no working sets found, try to use the last set regardless of warmup status
        if let lastSet = previousSets.last {
            return (lastSet.weightKg, lastSet.reps)
        }
        
        return (nil, nil)
    }
    
    /// Rounds weight to match equipment constraints (pin-loaded/cable machines).
    /// Uses template resistance equipment. Optional preferred unit selects first range matching that unit.
    /// Returns rounded weight in kg, or original weight if no matching equipment found.
    @MainActor
    static func roundWeightToEquipmentIncrement(
        weightKg: Double,
        exercise: ExerciseModel,
        gymProfile: GymProfileModel?,
        preferredWeightUnit: ExerciseWeightUnit? = nil
    ) -> Double {
        roundWeightToEquipmentIncrement(
            weightKg: weightKg,
            equipmentRefs: exercise.resistanceEquipment,
            gymProfile: gymProfile,
            preferredWeightUnit: preferredWeightUnit
        )
    }

    /// Rounds weight using the workout exercise's chosen resistance equipment.
    /// Uses first range whose unit matches preferredWeightUnit; if none, uses default or first active range.
    /// Returns rounded weight in kg, or original weight if chosen equipment is empty or no matching range.
    @MainActor
    static func roundWeightToEquipmentIncrement(
        weightKg: Double,
        workoutExercise: WorkoutExerciseModel,
        gymProfile: GymProfileModel?,
        preferredWeightUnit: ExerciseWeightUnit?
    ) -> Double {
        let refs = workoutExercise.chosenResistanceEquipment
        guard !refs.isEmpty else {
            return weightKg
        }
        return roundWeightToEquipmentIncrement(
            weightKg: weightKg,
            equipmentRefs: refs,
            gymProfile: gymProfile,
            preferredWeightUnit: preferredWeightUnit
        )
    }

    /// Internal: rounds weight using equipment refs, with gym fallback and optional preferred unit for range selection.
    @MainActor
    private static func roundWeightToEquipmentIncrement(
        weightKg: Double,
        equipmentRefs: [EquipmentRef],
        gymProfile: GymProfileModel?,
        preferredWeightUnit: ExerciseWeightUnit?
    ) -> Double {
        let gym = gymProfile ?? GymProfileModel(authorId: "")
        let fallbackGym = GymProfileModel(authorId: "")

        for equipmentRef in equipmentRefs {
            guard equipmentRef.kind == .pinLoadedMachine || equipmentRef.kind == .cableMachine else {
                continue
            }

            let weightRange: (any WeightRange)?

            switch equipmentRef.kind {
            case .pinLoadedMachine:
                let machine = gym.pinLoadedMachines.first(where: { $0.id == equipmentRef.equipmentId && $0.isActive })
                    ?? fallbackGym.pinLoadedMachines.first(where: { $0.id == equipmentRef.equipmentId })
                weightRange = machine.flatMap { resolveRange(for: $0, preferredWeightUnit: preferredWeightUnit) }
            case .cableMachine:
                let machine = gym.cableMachines.first(where: { $0.id == equipmentRef.equipmentId && $0.isActive })
                    ?? fallbackGym.cableMachines.first(where: { $0.id == equipmentRef.equipmentId })
                weightRange = machine.flatMap { resolveRange(for: $0, preferredWeightUnit: preferredWeightUnit) }
            default:
                weightRange = nil
            }

            guard let range = weightRange else {
                continue
            }

            let weightInEquipmentUnit = UnitConversion.convertWeight(weightKg, to: range.unit)
            let roundedInEquipmentUnit = floor(weightInEquipmentUnit / range.increment) * range.increment
            let clampedWeight = max(range.minWeight, min(range.maxWeight, roundedInEquipmentUnit))
            let roundedWeightKg = UnitConversion.convertWeightToKg(clampedWeight, from: range.unit)

            return roundedWeightKg
        }

        return weightKg
    }

    /// First range where unit matches preferredWeightUnit; else defaultRange or first active.
    @MainActor
    private static func resolveRange(for machine: CableMachine, preferredWeightUnit: ExerciseWeightUnit?) -> (any WeightRange)? {
        if let preferred = preferredWeightUnit,
           let match = machine.ranges.first(where: { $0.unit == preferred }) {
            return match
        }
        return machine.defaultRange ?? machine.ranges.first(where: { $0.isActive })
    }

    /// First range where unit matches preferredWeightUnit; else defaultRange or first active.
    @MainActor
    private static func resolveRange(for machine: PinLoadedMachine, preferredWeightUnit: ExerciseWeightUnit?) -> (any WeightRange)? {
        if let preferred = preferredWeightUnit,
           let match = machine.ranges.first(where: { $0.unit == preferred }) {
            return match
        }
        return machine.defaultRange ?? machine.ranges.first(where: { $0.isActive })
    }
    
    /// Rounds weight to user's preferred unit (0.5kg increments for kg, whole numbers for lbs)
    static func roundWeightToPreferredUnit(
        weightKg: Double?,
        preferredUnit: ExerciseWeightUnit
    ) -> Double? {
        guard let weightKg = weightKg else { return nil }
        
        // Convert to preferred unit
        let weightInPreferredUnit = UnitConversion.convertWeight(weightKg, to: preferredUnit)
        
        // Round based on unit
        let roundedWeight: Double
        switch preferredUnit {
        case .kilograms:
            // Round to nearest 0.5kg
            roundedWeight = round(weightInPreferredUnit * 2) / 2.0
        case .pounds:
            // Round to nearest whole number
            roundedWeight = round(weightInPreferredUnit)
        }
        
        // Convert back to kg for storage
        return UnitConversion.convertWeightToKg(roundedWeight, from: preferredUnit)
    }
    
    static func defaultSets(
        trackingMode: TrackingMode,
        authorId: String,
        targetCount: Int = 3
    ) -> [WorkoutSetModel] {
        let count = max(targetCount, 1)
        switch trackingMode {
        case .weightReps:
            return (0..<count).map { index in
                WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: index + 1, reps: nil,
                                weightKg: nil, durationSec: nil, distanceMeters: nil, rpe: nil,
                                isWarmup: false, completedAt: nil, dateCreated: .now)
            }
        case .repsOnly:
            return (0..<count).map { index in
                WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: index + 1, reps: nil,
                                weightKg: nil, durationSec: nil, distanceMeters: nil, rpe: nil,
                                isWarmup: false, completedAt: nil, dateCreated: .now)
            }
        case .timeOnly:
            return (0..<count).map { index in
                WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: index + 1, reps: nil,
                                    weightKg: nil, durationSec: 60, distanceMeters: nil, rpe: nil,
                                    isWarmup: false, completedAt: nil, dateCreated: .now)
            }
        case .distanceTime:
            return (0..<count).map { index in
                WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: index + 1, reps: nil,
                                    weightKg: nil, durationSec: 120, distanceMeters: 400, rpe: nil,
                                    isWarmup: false, completedAt: nil, dateCreated: .now)
            }
        }
    }
    
    @MainActor
    static var mock: WorkoutSessionModel {
        mocks[0]
    }
    
    @MainActor
    static var mocks: [WorkoutSessionModel] {
        // Ensure mock sessions belong to the preview/mock user and are completed so they appear in history
        let uid = "uid"
        var session1 = WorkoutSessionModel(id: "session-1", authorId: uid, template: WorkoutTemplateModel.mocks[0])
        session1.endSession(at: session1.dateCreated.addingTimeInterval(45 * 60))
        var session2 = WorkoutSessionModel(id: "session-2", authorId: uid, template: WorkoutTemplateModel.mocks[1])
        session2.endSession(at: session2.dateCreated.addingTimeInterval(30 * 60))
        var session3 = WorkoutSessionModel(id: "session-3", authorId: uid, template: WorkoutTemplateModel.mocks[2])
        session3.endSession(at: session3.dateCreated.addingTimeInterval(60 * 60))
        return [session1, session2, session3]
    }
}
