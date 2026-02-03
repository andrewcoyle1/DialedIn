//
//  TrainingProgram.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI

struct TrainingProgram: Identifiable, Codable {
    var id: String
    var authorId: String
    var name: String
    var icon: String
    var colour: String
    var numMicrocycles: Int = 8
    var deload: DeloadType = .none
    var periodisation: Bool = false
    var dayPlans: [DayPlan] = defaultDayPlans
    let dateCreated: Date
    let dateModified: Date
    
    init(
        id: String = UUID().uuidString,
        authorId: String,
        name: String,
        icon: String,
        colour: String,
        numMicrocycles: Int = 8,
        deload: DeloadType = .none,
        periodisation: Bool = false,
        dayPlans: [DayPlan] = defaultDayPlans,
        dateCreated: Date = Date(),
        dateModified: Date = Date()
    ) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.icon = icon
        self.colour = colour
        self.numMicrocycles = numMicrocycles
        self.deload = deload
        self.periodisation = periodisation
        self.dayPlans = dayPlans
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name
        case icon
        case colour
        case numMicrocycles = "num_microcycles"
        case deload
        case periodisation
        case dayPlans = "day_plans"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }

    static var defaultDayPlans: [DayPlan] = [
        DayPlan(id: UUID().uuidString, authorId: "", name: "Rest", dateCreated: Date(), exercises: [])
    ]
    
    static var mock: TrainingProgram {
        mocks[0]
    }
    
    static var mocks: [TrainingProgram] {
        [
            TrainingProgram(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Mock Training Program",
                icon: "dumbbell",
                colour: Color.red.asHex(),
                numMicrocycles: 8,
                deload: .none,
                periodisation: false,
                dayPlans: DayPlan.mocks
            )
        ]
    }

}

enum DeloadType: String, Hashable, Codable {
    case none
    case start
    case end
    
    var title: String {
        switch self {
        case .none: return "None"
        case .start: return "First Cycle"
        case .end: return "Last Cycle"
        }
    }
    
    var description: String {
        switch self {
        case .none: return "Train continuously without scheduled reductions in intensity or volume."
        case .start: return "Start each training block with a lower-intensity cycle to ease into new workloads and reduce soreness."
        case .end: return "Finish each training block with a lighter cycle to promote recovery and readiness for the next phase."
        }
    }
}
