//
//  CoreBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/11/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct CoreBuilder: Builder {

    let interactor: CoreInteractor
    
    init(interactor: CoreInteractor) {
        self.interactor = interactor
    }
    
    init(container: DependencyContainer) {
        self.interactor = CoreInteractor(container: container)
    }
    
    func build() -> AnyView {
        adaptiveMainView()
            .any()
    }

}
