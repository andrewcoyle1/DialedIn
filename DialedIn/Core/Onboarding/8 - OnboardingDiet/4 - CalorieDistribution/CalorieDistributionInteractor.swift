//
//  CalorieDistributionInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol CalorieDistributionInteractor: GlobalInteractor {
    var activeTrainingProgram: TrainingProgram? { get }
}

extension CoreInteractor: CalorieDistributionInteractor { }
