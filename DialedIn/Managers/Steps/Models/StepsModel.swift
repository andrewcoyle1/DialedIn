//
//  StepsEntry.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import Foundation

struct StepsModel: DataSyncModelProtocol {
    let id: String
    let authorId: String
    var number: Int
    let date: Date
    let source: StepsSource
    let dateCreated: Date
    var dateModified: Date
    let deletedAt: Date?
    let healthKitId: String?

    init(
        id: String = UUID().uuidString,
        authorId: String,
        number: Int,
        date: Date,
        source: StepsSource = .manual,
        dateCreated: Date = Date.now,
        dateModified: Date = Date.now,
        deletedAt: Date? = nil,
        healthKitId: String? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.number = number
        self.date = date
        self.source = source
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.deletedAt = deletedAt
        self.healthKitId = healthKitId
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case number
        case date
        case source
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case deletedAt = "deleted_at"
        case healthKitId = "healthkit_id"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "steps_\(CodingKeys.id.rawValue)": id,
            "steps_\(CodingKeys.authorId.rawValue)": authorId,
            "steps_\(CodingKeys.number.rawValue)": number,
            "steps_\(CodingKeys.date.rawValue)": date,
            "steps_\(CodingKeys.source.rawValue)": source.rawValue,
            "steps_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "steps_\(CodingKeys.dateModified.rawValue)": dateModified,
            "steps_\(CodingKeys.deletedAt.rawValue)": deletedAt,
            "steps_\(CodingKeys.healthKitId.rawValue)": healthKitId
        ]
        return dict.compactMapValues({ $0 })

    }
    
    static var mock: StepsModel {
        mocks[0]
    }
    
    static let mocks: [StepsModel] =
    [
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now.addingTimeInterval(days: -7)),
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now.addingTimeInterval(days: -6)),
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now.addingTimeInterval(days: -5)),
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now.addingTimeInterval(days: -4)),
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now.addingTimeInterval(days: -3)),
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now.addingTimeInterval(days: -2)),
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now.addingTimeInterval(days: -1)),
        StepsModel(authorId: UserModel.mock.userId, number: 3000, date: .now)
    ]
}

enum StepsSource: String, Codable {
    case manual
    case healthkit
    case imported

    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .healthkit: return "HealthKit"
        case .imported: return "Imported"
        }
    }
}
