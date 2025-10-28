//
//  FirebaseAnalyticsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/25/24.
//
import FirebaseAnalytics
import Foundation

fileprivate extension String {
    
    func clean(maxCharacters: Int) -> String {
        self
            .clipped(maxCharacters: maxCharacters)
            .replaceSpacesWithUnderscores()
    }
}

struct FirebaseAnalyticsService: LogService {
    
    func identifyUser(userId: String, name: String?, email: String?) {
        Analytics.setUserID(userId)
        
        if let name {
            Analytics.setUserProperty(name, forName: "account_name")
        }
        if let email {
            Analytics.setUserProperty(email, forName: "account_email")
        }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        
        for (key, value) in dict {
            if let string = String.convertToString(value) {
                let alias: [String: String] = [
                    "user_weight_unit_preference": "weight_unit",
                    "user_daily_activity_level": "activity_level",
                    "user_length_unit_preference": "length_unit",
                    "user_did_complete_onboarding": "onboarded",
                    "user_cardio_fitness_level": "cardio_level"
                ]
                let rawKey = alias[key] ?? key
                let key = rawKey.clean(maxCharacters: 24)
                let string = string.clean(maxCharacters: 36)
                Analytics.setUserProperty(string, forName: key)
            }
        }
    }
    
    func deleteUserProfile() {
        
    }
    
    func trackEvent(event: any LoggableEvent) {
        guard event.type != .info else { return }
        
        var parameters = event.parameters ?? [:]
        
        // Fix any values that are bad types
        for (key, value) in parameters {
            
            if let date = value as? Date, let string = String.convertToString(date) {
                parameters[key] = string
                
            } else if let array = value as? [Any] {
                if let string = String.convertToString(array) {
                    parameters[key] = string
                } else {
                    parameters[key] = nil
                }
            }
        }
        
        // Fix key length limits
        for (key, value) in parameters where key.count > 40 {
            parameters.removeValue(forKey: key)
            
            let newKey = key.clean(maxCharacters: 40)
            parameters[newKey] = value
        }
        
        // Fix value length limits
        for (key, value) in parameters {
            if let string = value as? String {
                parameters[key] = string.clean(maxCharacters: 100)
            }
        }
        
        // Limit to 25 parameters
        var limited: [String: Any] = [:]
        limited.reserveCapacity(min(parameters.count, 25))
        var count = 0
        for (key, value) in parameters {
            limited[key] = value
            count += 1
            if count >= 25 { break }
        }
        parameters = limited
        
        let name = event.eventName.clean(maxCharacters: 40)
        Analytics.logEvent(name, parameters: parameters.isEmpty ? nil : parameters)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        let name = event.eventName.clean(maxCharacters: 40)
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
    }

}
