//
//  ProductionTrainingPlanServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionTrainingPlanServices: TrainingPlanServices {
    let remote: RemoteTrainingPlanService
    let local: LocalTrainingPlanPersistence
    
    @MainActor
    init() {
        self.remote = FirebaseTrainingPlanService()
        self.local = SwiftTrainingPlanPersistence()
    }
}
