//
//  WeightEntry.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct WeightEntry: Codable, Identifiable, Equatable {
    let id: String
    let authorId: String
    let weightKg: Double
    let bodyFatPercentage: Double?
    let date: Date
    let source: WeightSource
    let notes: String?
    let dateCreated: Date
    let deletedAt: Date?
    let healthKitUUID: UUID?
    
    init(
        id: String = UUID().uuidString,
        authorId: String,
        weightKg: Double,
        bodyFatPercentage: Double? = nil,
        date: Date,
        source: WeightSource = .manual,
        notes: String? = nil,
        dateCreated: Date = Date(),
        deletedAt: Date? = nil,
        healthKitUUID: UUID? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.weightKg = weightKg
        self.bodyFatPercentage = bodyFatPercentage
        self.date = date
        self.source = source
        self.notes = notes
        self.dateCreated = dateCreated
        self.deletedAt = deletedAt
        self.healthKitUUID = healthKitUUID
    }
        
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case weightKg = "weight_kg"
        case bodyFatPercentage = "body_fat_percentage"
        case date
        case source
        case notes
        case dateCreated = "date_created"
        case deletedAt = "deleted_at"
        case healthKitUUID = "healthkit_uuid"
    }
}

// MARK: - Mock Data
extension WeightEntry {
    static var mock: WeightEntry {
        mocks[0]
    }
    
    static var mocks: [WeightEntry] {
        (0..<500).map { datapoint in
            // Use a sinusoidal function to vary the weight between ~70 and ~75 kg
            let baseWeight: Double = 72.0
            let amplitude: Double = 2.5
            let period: Double = 100.0 // 100 days per complete sine cycle
            let weight = baseWeight + amplitude * sin(Double(datapoint) * 2 * .pi / period)
            let bodyFatBase: Double = 16.0
            let bodyFatAmplitude: Double = 1.2
            let bodyFatPercent = bodyFatBase + bodyFatAmplitude * sin(Double(datapoint) * 2 * .pi / 120.0)
            let date = Date.now.addingTimeInterval(Double(-86400 * datapoint))
            return WeightEntry(
                authorId: "user_123",
                weightKg: weight,
                bodyFatPercentage: bodyFatPercent,
                date: date
            )
        }
    }
}

extension WeightEntry: @MainActor MetricEntry {
    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        weightKg.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "scalemass"
    }

    func timeSeriesData() -> [(seriesName: String, date: Date, value: Double)] {
        var series: [(seriesName: String, date: Date, value: Double)] = [
            ("Weight", date, weightKg)
        ]
        if let bodyFatPercentage {
            series.append(("Body Fat", date, bodyFatPercentage))
        }
        return series
    }
}
