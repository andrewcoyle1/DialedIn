//
//  AdaptiveMainRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/01/2026.
//

@MainActor
protocol AdaptiveMainRouter: GlobalRouter { }

extension CoreRouter: AdaptiveMainRouter { }
