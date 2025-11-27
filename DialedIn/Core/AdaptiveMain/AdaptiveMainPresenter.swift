//
//  AdaptiveMainPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/10/2025.
//

import Foundation

@Observable
@MainActor
class AdaptiveMainPresenter {
    private let interactor: AdaptiveMainInteractor
        
    init(interactor: AdaptiveMainInteractor) {
        self.interactor = interactor
    }
}
