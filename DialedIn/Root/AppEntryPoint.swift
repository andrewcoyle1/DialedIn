//
//  AppEntryPoint.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/10/2025.
//

import SwiftUI
import SwiftfulUtilities

@main
struct AppEntryPoint {
    
    static func main() {
        if SwiftfulUtilities.Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            DialedInApp.main()
        }
    }
}
