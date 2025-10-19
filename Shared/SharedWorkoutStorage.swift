//
//  SharedWorkoutStorage.swift
//  DialedIn
//
//  Created by AI Assistant on 17/10/2025.
//

import Foundation

/// Shared storage for workout data that needs to be accessed by both the main app and widget extension
public struct SharedWorkoutStorage {
    private static let appGroupIdentifier = "group.com.dialedin.app"
    private static let restEndTimeKey = "workout.rest.endTime"
    private static let pendingSetCompletionKey = "workout.pending.setCompletion"
    private static let pendingWorkoutCompletionKey = "workout.pending.workoutCompletion"
    
    private static var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    /// Get the current rest end time
    public static var restEndTime: Date? {
        get {
            guard let defaults = sharedDefaults,
                  let timestamp = defaults.object(forKey: restEndTimeKey) as? TimeInterval else {
                return nil
            }
            return Date(timeIntervalSince1970: timestamp)
        }
        set {
            guard let defaults = sharedDefaults else { return }
            if let newValue = newValue {
                defaults.set(newValue.timeIntervalSince1970, forKey: restEndTimeKey)
            } else {
                defaults.removeObject(forKey: restEndTimeKey)
            }
        }
    }
    
    /// Clear the rest end time
    public static func clearRestEndTime() {
        restEndTime = nil
    }
    
    // MARK: - Set Completion Communication
    
    /// Represents a set completion request from the widget
    public struct PendingSetCompletion: Codable {
        public let setId: String
        public let weightKg: Double?
        public let reps: Int?
        public let distanceMeters: Double?
        public let durationSec: Int?
        public let completedAt: Date
        
        public init(setId: String, weightKg: Double?, reps: Int?, distanceMeters: Double?, durationSec: Int?, completedAt: Date) {
            self.setId = setId
            self.weightKg = weightKg
            self.reps = reps
            self.distanceMeters = distanceMeters
            self.durationSec = durationSec
            self.completedAt = completedAt
        }
    }
    
    /// Get pending set completion from widget
    public static var pendingSetCompletion: PendingSetCompletion? {
        get {
            guard let defaults = sharedDefaults,
                  let data = defaults.data(forKey: pendingSetCompletionKey),
                  let completion = try? JSONDecoder().decode(PendingSetCompletion.self, from: data) else {
                return nil
            }
            return completion
        }
        set {
            guard let defaults = sharedDefaults else { return }
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: pendingSetCompletionKey)
            } else {
                defaults.removeObject(forKey: pendingSetCompletionKey)
            }
        }
    }
    
    /// Clear pending set completion
    public static func clearPendingSetCompletion() {
        pendingSetCompletion = nil
    }
    
    // MARK: - Workout Completion Communication
    
    /// Represents a workout completion request from the widget
    public struct PendingWorkoutCompletion: Codable {
        public let sessionId: String
        public let completedAt: Date
        
        public init(sessionId: String, completedAt: Date) {
            self.sessionId = sessionId
            self.completedAt = completedAt
        }
    }
    
    /// Get pending workout completion from widget
    public static var pendingWorkoutCompletion: PendingWorkoutCompletion? {
        get {
            guard let defaults = sharedDefaults,
                  let data = defaults.data(forKey: pendingWorkoutCompletionKey),
                  let completion = try? JSONDecoder().decode(PendingWorkoutCompletion.self, from: data) else {
                return nil
            }
            return completion
        }
        set {
            guard let defaults = sharedDefaults else { return }
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: pendingWorkoutCompletionKey)
            } else {
                defaults.removeObject(forKey: pendingWorkoutCompletionKey)
            }
        }
    }
    
    /// Clear pending workout completion
    public static func clearPendingWorkoutCompletion() {
        pendingWorkoutCompletion = nil
    }
}
