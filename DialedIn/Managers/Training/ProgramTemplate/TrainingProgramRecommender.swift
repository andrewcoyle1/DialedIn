//
//  TrainingProgramRecommender.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import Foundation

struct TrainingProgramRecommender {
    
    /// Recommends a program template based on user preferences
    /// - Parameters:
    ///   - preference: User's training preferences
    ///   - availableTemplates: List of available program templates
    /// - Returns: Recommended template ID, or nil if no suitable match
    static func recommendTemplate(
        preference: ProgramPreference,
        availableTemplates: [ProgramTemplateModel]
    ) -> ProgramTemplateModel? {
        guard !availableTemplates.isEmpty else {
            return nil
        }
        
        // Score each template based on how well it matches preferences
        let scoredTemplates = availableTemplates.map { template -> (template: ProgramTemplateModel, score: Int) in
            (template, scoreForTemplate(template: template, preference: preference))
        }
        
        return selectBestTemplate(scoredTemplates: scoredTemplates, availableTemplates: availableTemplates, preference: preference)
    }
    
    /// Computes a score for a template given the user's preferences
    private static func scoreForTemplate(template: ProgramTemplateModel, preference: ProgramPreference) -> Int {
        var score = 0
        
        // Match difficulty level (high weight)
        if template.difficulty == preference.experienceLevel {
            score += 10
        } else {
            // Partial match: beginner -> intermediate gets some points
            if preference.experienceLevel == .beginner && template.difficulty == .intermediate {
                score += 3
            } else if preference.experienceLevel == .intermediate && template.difficulty == .advanced {
                score += 2
            }
        }
        
        // Match days per week based on template's typical schedule
        let templateDaysPerWeek = template.weekTemplates.first?.workoutSchedule.count ?? 0
        let daysDifference = abs(templateDaysPerWeek - preference.targetDaysPerWeek)
        if daysDifference == 0 {
            score += 8
        } else if daysDifference == 1 {
            score += 5
        } else if daysDifference == 2 {
            score += 2
        }
        
        // Match split type based on template structure
        let templateSplit = inferSplitType(from: template)
        if templateSplit == preference.splitType {
            score += 7
        } else if isCompatibleSplit(templateSplit, preference.splitType) {
            score += 3
        }
        
        // Equipment compatibility (lower weight, but still important)
        if hasCompatibleEquipment(template: template, available: preference.availableEquipment) {
            score += 3
        }
        
        return score
    }
    
    /// Selects the best template from scored results with sensible fallbacks
    private static func selectBestTemplate(
        scoredTemplates: [(template: ProgramTemplateModel, score: Int)],
        availableTemplates: [ProgramTemplateModel],
        preference: ProgramPreference
    ) -> ProgramTemplateModel? {
        let sorted = scoredTemplates.sorted { $0.score > $1.score }
        if let bestMatch = sorted.first, bestMatch.score > 0 {
            return bestMatch.template
        }
        if let difficultyMatch = availableTemplates.first(where: { $0.difficulty == preference.experienceLevel }) {
            return difficultyMatch
        }
        return availableTemplates.first
    }
    
    /// Infers the split type from a template's structure
    private static func inferSplitType(from template: ProgramTemplateModel) -> TrainingSplitType {
        guard let firstWeek = template.weekTemplates.first else {
            return .fullBody
        }
        
        let workoutCount = firstWeek.workoutSchedule.count
        
        // Check workout names for hints
        let workoutNames = firstWeek.workoutSchedule.compactMap { $0.workoutName?.lowercased() }
        
        if workoutNames.contains(where: { $0.contains("push") || $0.contains("pull") || $0.contains("leg") }) {
            return .pushPullLegs
        }
        
        if workoutNames.contains(where: { $0.contains("upper") || $0.contains("lower") }) {
            return .upperLower
        }
        
        if workoutNames.contains(where: { $0.contains("full body") || $0.contains("fullbody") }) {
            return .fullBody
        }
        
        // Infer from workout count
        switch workoutCount {
        case 1...3:
            return .fullBody
        case 4:
            return .upperLower
        case 5...6:
            return .pushPullLegs
        default:
            return .bodyPartSplit
        }
    }
    
    /// Checks if two split types are compatible
    private static func isCompatibleSplit(_ split1: TrainingSplitType, _ split2: TrainingSplitType) -> Bool {
        if split1 == split2 {
            return true
        }
        
        // Full body is compatible with upper/lower for beginners
        if (split1 == .fullBody && split2 == .upperLower) || (split1 == .upperLower && split2 == .fullBody) {
            return true
        }
        
        return false
    }
    
    /// Checks if template is compatible with available equipment
    /// This is a simplified check - in a real implementation, you'd check exercise templates
    private static func hasCompatibleEquipment(template: ProgramTemplateModel, available: Set<EquipmentType>) -> Bool {
        // For now, assume all templates are compatible if user has basic equipment
        // In a full implementation, you'd check the exercises in workout templates
        if available.contains(.bodyweight) || available.contains(.dumbbell) || available.contains(.barbell) {
            return true
        }
        
        return false
    }
}
