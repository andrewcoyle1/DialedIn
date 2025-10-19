//
//  DetailNavigationModel.swift
//  DialedIn
//
//  Created by AI Assistant on 18/10/2025.
//

import SwiftUI
import Observation

@Observable
final class DetailNavigationModel {
    var path: [NavigationPathOption] = []

    func clear() {
        path.removeAll()
    }
}
