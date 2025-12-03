//
//  TabBarScreen.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/12/2025.
//

import SwiftUI

struct TabBarScreen: Identifiable {
    var id: String {
        title
    }

    let title: String
    let systemImage: String
    @ViewBuilder var screen: () -> AnyView
}
