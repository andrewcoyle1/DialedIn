//
//  DialedInUITests.swift
//  DialedInUITests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import XCTest

@MainActor
final class DialedInUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {

    }

    func testSignedInExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()        
    }
    
    func testSignedOutExample() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
}
