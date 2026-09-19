import SwiftUI
import Foundation

enum BodyMetricType: Hashable {
    case scaleWeight
    case visualBodyFat
    case neck
    case shoulders
    case bust
    case chest
    case waist
    case hips
    case leftBicep
    case rightBicep
    case leftForearm
    case rightForearm
    case leftWrist
    case rightWrist
    case leftThigh
    case rightThigh
    case leftCalf
    case rightCalf
    case leftAnkle
    case rightAnkle
}

@MainActor
extension BodyMetricType {

    func value(from entry: BodyMeasurementEntry) -> Double? {
        entry[keyPath: Self.valueKeyPaths[self]!]
    }

    var displayTitle: String {
        Self.displayTitles[self]!
    }

    /// What the stored number means, so display code knows which conversion to apply. Storage is
    /// kilograms for weight and centimetres for every circumference.
    enum Measure {
        case weightKilograms
        case lengthCentimeters
        case percentage
    }

    var measure: Measure {
        switch self {
        case .scaleWeight:   return .weightKilograms
        case .visualBodyFat: return .percentage
        default:             return .lengthCentimeters
        }
    }

    private static let valueKeyPaths: [BodyMetricType: KeyPath<BodyMeasurementEntry, Double?>] = [
        .scaleWeight: \BodyMeasurementEntry.weightKg,
        .visualBodyFat: \BodyMeasurementEntry.bodyFatPercentage,
        .neck: \BodyMeasurementEntry.neckCircumference,
        .shoulders: \BodyMeasurementEntry.shoulderCircumference,
        .bust: \BodyMeasurementEntry.bustCircumference,
        .chest: \BodyMeasurementEntry.chestCircumference,
        .waist: \BodyMeasurementEntry.waistCircumference,
        .hips: \BodyMeasurementEntry.hipCircumference,
        .leftBicep: \BodyMeasurementEntry.leftBicepCircumference,
        .rightBicep: \BodyMeasurementEntry.rightBicepCircumference,
        .leftForearm: \BodyMeasurementEntry.leftForearmCircumference,
        .rightForearm: \BodyMeasurementEntry.rightForearmCircumference,
        .leftWrist: \BodyMeasurementEntry.leftWristCircumference,
        .rightWrist: \BodyMeasurementEntry.rightWristCircumference,
        .leftThigh: \BodyMeasurementEntry.leftThighCircumference,
        .rightThigh: \BodyMeasurementEntry.rightThighCircumference,
        .leftCalf: \BodyMeasurementEntry.leftCalfCircumference,
        .rightCalf: \BodyMeasurementEntry.rightCalfCircumference,
        .leftAnkle: \BodyMeasurementEntry.leftAnkleCircumference,
        .rightAnkle: \BodyMeasurementEntry.rightAnkleCircumference
    ]

    private static let displayTitles: [BodyMetricType: String] = [
        .scaleWeight: "Scale Weight",
        .visualBodyFat: "Visual Body Fat",
        .neck: "Neck",
        .shoulders: "Shoulders",
        .bust: "Bust",
        .chest: "Chest",
        .waist: "Waist",
        .hips: "Hips",
        .leftBicep: "Left Bicep",
        .rightBicep: "Right Bicep",
        .leftForearm: "Left Forearm",
        .rightForearm: "Right Forearm",
        .leftWrist: "Left Wrist",
        .rightWrist: "Right Wrist",
        .leftThigh: "Left Thigh",
        .rightThigh: "Right Thigh",
        .leftCalf: "Left Calf",
        .rightCalf: "Right Calf",
        .leftAnkle: "Left Ankle",
        .rightAnkle: "Right Ankle"
    ]

}

struct BodyMetricCardModel: Identifiable {
    let id: BodyMetricType
    let title: String
    let subtitle: String
    let latestValueText: String
    let unitText: String
    let sparklineData: [(date: Date, value: Double)]
}

/// A derived ratio card. Separate from `BodyMetricCardModel` because a ratio has no unit to print
/// and is keyed by `BodyRatioKind` rather than `BodyMetricType`.
struct BodyRatioCardModel: Identifiable {
    let id: BodyRatioKind
    let title: String
    let subtitle: String
    let latestValueText: String
    let sparklineData: [(date: Date, value: Double)]
}

struct BodyMetricsSection: Identifiable {
    let id: String
    let header: String
    let cards: [BodyMetricCardModel]
}
