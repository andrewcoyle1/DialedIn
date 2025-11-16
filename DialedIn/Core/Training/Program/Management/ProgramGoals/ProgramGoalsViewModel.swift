//
//  ProgramGoalsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProgramGoalsInteractor {
    
}

extension CoreInteractor: ProgramGoalsInteractor { }

@Observable
@MainActor
class ProgramGoalsViewModel {
    private let interactor: ProgramGoalsInteractor
    
    var showAddGoal: Bool = false
    
    init(interactor: ProgramGoalsInteractor) {
        self.interactor = interactor
    }
}
