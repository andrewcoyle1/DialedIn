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

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
    }
}
