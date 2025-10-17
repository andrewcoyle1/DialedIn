//
//  TrainingPlan.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation

struct TrainingPlan: Codable, Equatable {
    
    let planId: String
    let userId: String?
    let createdAt: Date
    
}
