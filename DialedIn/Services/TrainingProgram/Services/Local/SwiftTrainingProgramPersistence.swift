//
//  SwiftTrainingProgramPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftTrainingProgramPersistence: LocalTrainingProgramPersistence {
    
    private let container: ModelContainer
    
    @MainActor
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: TrainingProgramEntity.self)
    }
    
}
