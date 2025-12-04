//
//  Buildable.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import CustomRouting
@MainActor
protocol Builder {
    func build() -> AnyView
}
