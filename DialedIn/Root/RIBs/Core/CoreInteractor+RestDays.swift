//
//  CoreInteractor+RestDays.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import Foundation

extension CoreInteractor {

    func preCompleteConsecutiveRestDays(after session: WorkoutSessionModel) async {
        guard
            let userId = try? authManager.getAuthId(),
            let programId = session.trainingProgramId,
            let templateId = session.workoutTemplateId
        else { return }

        guard let program = self.activeTrainingProgram,
              program.id == programId else { return }

        let restTemplates = consecutiveRestTemplates(after: templateId, in: program)
        guard !restTemplates.isEmpty else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let existingSessions = workoutSessionManager.workoutSessions

        for (offset, restTemplate) in restTemplates.enumerated() {
            let restDate = calendar.date(byAdding: .day, value: offset + 1, to: today)!

            let alreadyExists = existingSessions.contains { session in
                session.isRestDay &&
                session.workoutTemplateId == restTemplate.id &&
                calendar.isDate(session.dateCreated, inSameDayAs: restDate)
            }
            guard !alreadyExists else { continue }

            let restSession = WorkoutSessionModel(
                authorId: userId,
                name: restTemplate.name,
                workoutTemplateId: restTemplate.id,
                trainingProgramId: programId,
                dateCreated: restDate,
                endedAt: restDate,
                exercises: [],
                isRestDay: true
            )
            try? await workoutSessionManager.saveWorkoutSession(restSession)
        }
    }

    private func consecutiveRestTemplates(
        after templateId: String,
        in program: TrainingProgram
    ) -> [WorkoutTemplateModel] {
        let templates = program.workoutTemplates
        guard let idx = templates.firstIndex(where: { $0.id == templateId }) else { return [] }
        var rests: [WorkoutTemplateModel] = []
        var next = idx + 1
        while next < templates.count, templates[next].exercises.isEmpty {
            rests.append(templates[next])
            next += 1
        }
        return rests
    }

}
