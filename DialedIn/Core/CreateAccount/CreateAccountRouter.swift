//
//  CreateAccountRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CreateAccountRouter {
    func dismissScreen()
}

extension CoreRouter: CreateAccountRouter { }
