//
//  StepsEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import SwiftUI
import SwiftData

@Model
class StepsEntity {
    
    @Attribute(.unique) var id: String
    var authorId: String
    var number: Int
    var date: Date
    var source: StepsSource
    var dateCreated: Date
    var dateModified: Date
    
    init(from model: StepsModel) {
        self.id = model.id
        self.authorId = model.authorId
        self.number = model.number
        self.date = model.date
        self.source = model.source
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
    }
    
    @MainActor
    func toModel() -> StepsModel {
        StepsModel(
            id: id,
            authorId: authorId,
            number: number,
            date: date,
            source: source, 
            dateCreated: dateCreated,
            dateModified: dateModified
        )
    }
}
