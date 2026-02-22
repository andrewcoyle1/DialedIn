//
//  TrainingPresenter+WorkoutStart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/02/2026.
//

import Foundation

@MainActor
extension TrainingPresenter {
    
    /// Handles workout start request by loading previous session, gym profile, and unit preferences
    func handleWorkoutStartRequest(
        template: WorkoutTemplateModel,
        programId: String? = nil,
        dayPlanId: String? = nil
    ) {
        guard let userId = currentUser?.userId else { return }
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: template,
                programId: programId,
                dayPlanId: dayPlanId,
                onStartWorkoutPressed: {
                    Task { @MainActor in
                        await self.startWorkoutSession(
                            template: template,
                            userId: userId,
                            programId: programId,
                            dayPlanId: dayPlanId
                        )
                    }
                },
                onCancelPressed: {
                    self.router.dismissModal()
                }
            )
        )
    }
    
    /// Creates and starts a workout session with smart progression
    private func startWorkoutSession(
        template: WorkoutTemplateModel,
        userId: String,
        programId: String?,
        dayPlanId: String?
    ) async {
        do {
            let previousSession = await loadPreviousWorkoutSession(template: template, userId: userId)
            let gymProfile = await loadGymProfile()
            let unitPreferences = loadUnitPreferences(for: template)
            
            let session = WorkoutSessionModel(
                authorId: userId,
                template: template,
                notes: nil,
                trainingPlanId: nil,
                programId: programId,
                dayPlanId: dayPlanId,
                previousWorkoutSession: previousSession,
                gymProfile: gymProfile,
                unitPreferences: unitPreferences
            )
            
            try interactor.addLocalWorkoutSession(session: session)
            interactor.startActiveSession(session)
            
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                router.dismissModal()
            }
            
            router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: session.id))
        } catch {
            router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
        }
    }
    
    /// Loads previous workout session for smart progression
    private func loadPreviousWorkoutSession(
        template: WorkoutTemplateModel,
        userId: String
    ) async -> WorkoutSessionModel? {
        print("🔥 [Smart Progression] Loading previous workout session for template: \(template.id)")
        
        // First try exact template ID match
        var previousSession = try? await interactor.getLastCompletedSessionForTemplate(
            templateId: template.id,
            authorId: userId
        )
        
        // If no exact match, try to find a session with matching exercises
        if previousSession == nil {
            previousSession = await findSessionWithMatchingExercises(template: template, userId: userId)
        }
        
        return previousSession
    }
    
    /// Finds a workout session with matching exercise template IDs
    private func findSessionWithMatchingExercises(
        template: WorkoutTemplateModel,
        userId: String
    ) async -> WorkoutSessionModel? {
        print("   🔍 No exact template ID match, searching by exercise template IDs...")
        let currentExerciseIds = Set(template.exercises.map { $0.exercise.id })
        print("   🔍 Current template has \(currentExerciseIds.count) exercises: \(currentExerciseIds)")
        
        guard let allSessions = try? interactor.getLocalWorkoutSessionsForAuthor(authorId: userId, limitTo: 0) else {
            return nil
        }
        
        let completedSessions = allSessions.filter { $0.endedAt != nil }
            .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
        
        for session in completedSessions {
            let sessionExerciseIds = Set(session.exercises.map { $0.templateId })
            print("   🔍 Session \(session.id) has exercises: \(sessionExerciseIds)")
            
            if sessionExerciseIds == currentExerciseIds {
                print("   ✅ Found session with matching exercises: \(session.id)")
                return session
            }
        }
        
        print("   ⚠️ No session found with matching exercises")
        return nil
    }
    
    /// Loads gym profile for equipment-aware weight rounding
    private func loadGymProfile() async -> GymProfileModel? {
        guard let favouriteGymProfileId = interactor.currentUser?.submittedFavouriteGymProfileId else {
            print("⚠️ [Equipment Rounding] No favourite gym profile ID found")
            return nil
        }
        
        do {
            let gymProfile = try interactor.readLocalGymProfile(profileId: favouriteGymProfileId)
            print("✅ [Equipment Rounding] Loaded gym profile: \(gymProfile.name)")
            return gymProfile
        } catch {
            print("⚠️ [Equipment Rounding] Failed to load gym profile locally, trying remote...")
            do {
                let gymProfile = try await interactor.readRemoteGymProfile(profileId: favouriteGymProfileId)
                print("✅ [Equipment Rounding] Loaded gym profile from remote: \(gymProfile.name)")
                return gymProfile
            } catch {
                print("⚠️ [Equipment Rounding] Failed to load gym profile: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    /// Loads unit preferences for all exercises in template
    private func loadUnitPreferences(for template: WorkoutTemplateModel) -> [String: ExerciseUnitPreference] {
        var unitPreferences: [String: ExerciseUnitPreference] = [:]
        for exerciseTemplate in template.exercises {
            let preference = interactor.getPreference(templateId: exerciseTemplate.exercise.id)
            unitPreferences[exerciseTemplate.exercise.id] = preference
        }
        return unitPreferences
    }
}
