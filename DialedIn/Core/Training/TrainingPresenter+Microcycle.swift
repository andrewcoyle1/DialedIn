//
//  TrainingPresenter+Microcycle.swift
//  DialedIn
//
//  Extracted for type_body_length and file_length.
//

import SwiftUI

struct MicrocycleCycleState {
    let cycleIndex: Int
    let cyclesTotal: Int
    let completedInCurrentCycle: Set<String>
}

// MARK: - Microcycle / Week Calendar
extension TrainingPresenter {

    func microcycleItemsForWeek(weekStart: Date, calendar: Calendar) -> [Date: MicrocycleWorkoutTemplateModelItem] {
        guard let program = activeTrainingProgram, !program.dayPlans.isEmpty else {
            microcycleHeaderText = "Current Microcycle"
            return [:]
        }
        let dayPlans = program.dayPlans
        let workoutWorkoutTemplateModelIds = Set(dayPlans.filter { !$0.exercises.isEmpty }.map { $0.id })
        let completedSessions = microcycleCompletedSessions(program: program, dayPlans: dayPlans)
        let weekDates = (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            .map { calendar.startOfDay(for: $0) }
        let weekDateSet = Set(weekDates)

        let cycleState = microcycleCycleState(
            program: program,
            completedSessions: completedSessions,
            workoutWorkoutTemplateModelIds: workoutWorkoutTemplateModelIds
        )
        microcycleHeaderText = "Microcycle \(cycleState.cycleIndex) of \(cycleState.cyclesTotal)"

        var itemsByDay = microcycleItemsFromCompleted(
            weekDateSet: weekDateSet,
            completedSessions: completedSessions,
            calendar: calendar
        )
        let startIndex = microcycleStartIndex(
            dayPlans: dayPlans,
            workoutWorkoutTemplateModelIds: workoutWorkoutTemplateModelIds,
            completedInCurrentCycle: cycleState.completedInCurrentCycle
        )
        var nextIndex = startIndex % dayPlans.count
        for day in weekDates where itemsByDay[day] == nil {
            let dayPlan = dayPlans[nextIndex]
            itemsByDay[day] = MicrocycleWorkoutTemplateModelItem(
                id: "\(day.timeIntervalSince1970)-\(dayPlan.id)",
                date: day,
                dayPlan: dayPlan,
                completedSessionId: nil
            )
            nextIndex = (nextIndex + 1) % dayPlans.count
        }
        return itemsByDay
    }

    func microcycleCompletedSessions(
        program: TrainingProgram,
        dayPlans: [WorkoutTemplateModel]
    ) -> [(WorkoutSessionModel, WorkoutTemplateModel)] {
        let dayPlanNames = Set(dayPlans.map { $0.name })
        let dayPlanById = Dictionary(uniqueKeysWithValues: dayPlans.map { ($0.id, $0) })
        return workoutSessions
            .compactMap { session -> (WorkoutSessionModel, WorkoutTemplateModel)? in
                guard session.endedAt != nil else { return nil }
                let shouldInclude = session.programId == program.id
                    || (session.programId == nil && session.dayPlanId == nil && dayPlanNames.contains(session.name))
                guard shouldInclude else { return nil }
                if let dayPlanId = session.dayPlanId, let plan = dayPlanById[dayPlanId] {
                    return (session, plan)
                }
                if let plan = dayPlans.first(where: { $0.name == session.name }) {
                    return (session, plan)
                }
                return nil
            }
            .sorted { ($0.0.endedAt ?? .distantPast) < ($1.0.endedAt ?? .distantPast) }
    }

    func microcycleCycleState(
        program: TrainingProgram,
        completedSessions: [(WorkoutSessionModel, WorkoutTemplateModel)],
        workoutWorkoutTemplateModelIds: Set<String>
    ) -> MicrocycleCycleState {
        let cyclesTotal = max(program.numMicrocycles, 1)
        var completedCycles = 0
        var completedInCurrentCycle = Set<String>()
        for (_, dayPlan) in completedSessions {
            guard workoutWorkoutTemplateModelIds.contains(dayPlan.id) else { continue }
            completedInCurrentCycle.insert(dayPlan.id)
            if completedInCurrentCycle == workoutWorkoutTemplateModelIds && !workoutWorkoutTemplateModelIds.isEmpty {
                completedCycles += 1
                completedInCurrentCycle.removeAll()
            }
        }
        let cycleIndex = min(completedCycles + 1, cyclesTotal)
        return MicrocycleCycleState(
            cycleIndex: cycleIndex,
            cyclesTotal: cyclesTotal,
            completedInCurrentCycle: completedInCurrentCycle
        )
    }

    func microcycleItemsFromCompleted(
        weekDateSet: Set<Date>,
        completedSessions: [(WorkoutSessionModel, WorkoutTemplateModel)],
        calendar: Calendar
    ) -> [Date: MicrocycleWorkoutTemplateModelItem] {
        var itemsByDay: [Date: MicrocycleWorkoutTemplateModelItem] = [:]
        for (session, dayPlan) in completedSessions {
            guard let endedAt = session.endedAt else { continue }
            let day = calendar.startOfDay(for: endedAt)
            guard weekDateSet.contains(day), itemsByDay[day] == nil else { continue }
            itemsByDay[day] = MicrocycleWorkoutTemplateModelItem(
                id: "\(day.timeIntervalSince1970)-\(dayPlan.id)",
                date: day,
                dayPlan: dayPlan,
                completedSessionId: session.id
            )
        }
        return itemsByDay
    }

    func microcycleStartIndex(
        dayPlans: [WorkoutTemplateModel],
        workoutWorkoutTemplateModelIds: Set<String>,
        completedInCurrentCycle: Set<String>
    ) -> Int {
        if workoutWorkoutTemplateModelIds.isEmpty { return 0 }
        if let first = dayPlans.firstIndex(where: { !$0.exercises.isEmpty && !completedInCurrentCycle.contains($0.id) }) {
            return first
        }
        return 0
    }

    func currentMicrocycleItems() -> [MicrocycleItem] {
        guard let program = activeTrainingProgram, !program.dayPlans.isEmpty else {
            microcycleHeaderText = "Current Microcycle"
            return []
        }

        let dayPlans = program.dayPlans
        let dayPlanNames = Set(dayPlans.map { $0.name })
        let dayPlanById = Dictionary(uniqueKeysWithValues: dayPlans.map { ($0.id, $0) })
        let workoutWorkoutTemplateModelIds = Set(dayPlans.filter { !$0.exercises.isEmpty }.map { $0.id })

        let completedSessions = workoutSessions
            .compactMap { session -> (WorkoutSessionModel, WorkoutTemplateModel)? in
                let shouldInclude = session.programId == program.id
                    || (session.programId == nil && session.dayPlanId == nil && dayPlanNames.contains(session.name))
                guard shouldInclude else { return nil }
                if let dayPlanId = session.dayPlanId, let plan = dayPlanById[dayPlanId] {
                    return (session, plan)
                }
                if let plan = dayPlans.first(where: { $0.name == session.name }) {
                    return (session, plan)
                }
                return nil
            }
            .sorted { ($0.0.endedAt ?? .distantPast) < ($1.0.endedAt ?? .distantPast) }

        let cyclesTotal = max(program.numMicrocycles, 1)
        var completedCycles = 0
        var completedInCurrentCycle = Set<String>()
        var sessionByPlanId: [String: String] = [:]
        for (session, dayPlan) in completedSessions {
            guard workoutWorkoutTemplateModelIds.contains(dayPlan.id) else { continue }
            if !completedInCurrentCycle.contains(dayPlan.id) {
                completedInCurrentCycle.insert(dayPlan.id)
                sessionByPlanId[dayPlan.id] = session.id
            }
            if completedInCurrentCycle == workoutWorkoutTemplateModelIds && !workoutWorkoutTemplateModelIds.isEmpty {
                completedCycles += 1
                completedInCurrentCycle.removeAll()
                sessionByPlanId.removeAll()
            }
        }
        let cycleIndex = min(completedCycles + 1, cyclesTotal)
        microcycleHeaderText = "Microcycle \(cycleIndex) of \(cyclesTotal)"

        return dayPlans.map { plan in
            MicrocycleItem(
                id: plan.id,
                dayPlan: plan,
                completedSessionId: sessionByPlanId[plan.id]
            )
        }
    }
}
