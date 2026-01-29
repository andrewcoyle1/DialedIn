//
//  TrainingPlanServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

protocol TrainingPlanServices {
    var remote: RemoteTrainingPlanService { get }
    var local: LocalTrainingPlanPersistence { get }
}
