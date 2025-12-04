//
//  Buildable.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI

@MainActor
protocol Buildable {
    func build() -> AnyView
}
