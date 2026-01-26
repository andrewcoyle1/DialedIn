//
//  SplitViewContainerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol SplitViewContainerInteractor {
    var activeSession: WorkoutSessionModel? { get }
}

extension CoreInteractor: SplitViewContainerInteractor { }
