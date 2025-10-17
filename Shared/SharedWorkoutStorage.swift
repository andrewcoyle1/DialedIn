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
}
