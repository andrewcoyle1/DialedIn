//
//  ProgramStartConfigInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProgramStartConfigInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramStartConfigInteractor { }
