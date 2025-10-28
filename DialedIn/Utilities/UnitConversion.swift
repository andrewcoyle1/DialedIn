//
//  UnitConversion.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/10/2025.
//

import Foundation

struct UnitConversion {
    
    // MARK: - Weight Conversion
    
    /// Convert kilograms to pounds
    static func kgToLbs(_ kilograms: Double) -> Double {
        return kilograms * 2.20462
    }
    
    /// Convert pounds to kilograms
    static func lbsToKg(_ lbs: Double) -> Double {
        return lbs / 2.20462
    }
    
    /// Convert weight from kg to the specified unit
    static func convertWeight(_ kilograms: Double, to unit: ExerciseWeightUnit) -> Double {
        switch unit {
        case .kilograms:
            return kilograms
        case .pounds:
            return kgToLbs(kilograms)
        }
    }
    
    /// Convert weight from the specified unit to kg
    static func convertWeightToKg(_ value: Double, from unit: ExerciseWeightUnit) -> Double {
        switch unit {
        case .kilograms:
            return value
        case .pounds:
            return lbsToKg(value)
        }
    }
    
    /// Format weight for display with appropriate decimal places
    static func formatWeight(_ kilograms: Double, unit: ExerciseWeightUnit) -> String {
        let converted = convertWeight(kilograms, to: unit)
        switch unit {
        case .kilograms:
            return String(format: "%.1f", converted)
        case .pounds:
            return String(format: "%.1f", converted)
        }
    }
    
    // MARK: - Distance Conversion
    
    /// Convert meters to miles
    static func metersToMiles(_ meters: Double) -> Double {
        return meters * 0.000621371
    }
    
    /// Convert miles to meters
    static func milesToMeters(_ miles: Double) -> Double {
        return miles / 0.000621371
    }
    
    /// Convert distance from meters to the specified unit
    static func convertDistance(_ meters: Double, to unit: ExerciseDistanceUnit) -> Double {
        switch unit {
        case .meters:
            return meters
        case .miles:
            return metersToMiles(meters)
        }
    }
    
    /// Convert distance from the specified unit to meters
    static func convertDistanceToMeters(_ value: Double, from unit: ExerciseDistanceUnit) -> Double {
        switch unit {
        case .meters:
            return value
        case .miles:
            return milesToMeters(value)
        }
    }
    
    /// Format distance for display with appropriate decimal places
    static func formatDistance(_ meters: Double, unit: ExerciseDistanceUnit) -> String {
        let converted = convertDistance(meters, to: unit)
        switch unit {
        case .meters:
            // Show in km if over 1000m
            if converted >= 1000 {
                return String(format: "%.2f km", converted / 1000)
            }
            return String(format: "%.0f m", converted)
        case .miles:
            return String(format: "%.2f", converted)
        }
    }
}
