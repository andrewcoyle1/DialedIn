//
//  AdaptiveMainViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/10/2025.
//

import Foundation

protocol AdaptiveMainInteractor {
    
}

extension CoreInteractor: AdaptiveMainInteractor { }

@Observable
@MainActor
class AdaptiveMainViewModel {
    private let interactor: AdaptiveMainInteractor
        
    init(interactor: AdaptiveMainInteractor) {
        self.interactor = interactor
    }
}
