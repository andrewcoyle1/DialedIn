//
//  ColorScheme+EXT.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

extension ColorScheme {
    
    var foregroundPrimary: Color {
        self == .dark ? Color.white : Color.black
    }

    var foregroundSecondary: Color {
        self == .dark ? Color.black : Color.white
    }

    var backgroundPrimary: Color {
        self == .dark ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground)
    }
    
    var backgroundSecondary: Color {
        self == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground)
    }

}
