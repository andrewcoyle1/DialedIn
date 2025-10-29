//
//  DialedInUITests.swift
//  DialedInUITests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import XCTest

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
        app/*@START_MENU_TOKEN@*/.images["dumbbell.fill"]/*[[".buttons[\"Training\"].images",".buttons.images[\"dumbbell.fill\"]",".images[\"dumbbell.fill\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["chevron.right"]/*[[".otherElements",".buttons[\"Forward\"]",".buttons[\"chevron.right\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["chevron.left"]/*[[".otherElements",".buttons[\"Back\"]",".buttons[\"chevron.left\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
    }
    
    func testSignedOutExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        app/*@START_MENU_TOKEN@*/.buttons["chevron.right"]/*[[".otherElements[\"chevron.right\"].buttons",".otherElements",".buttons[\"Forward\"]",".buttons[\"chevron.right\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Continue with Apple"]/*[[".otherElements.buttons[\"Continue with Apple\"]",".buttons[\"Continue with Apple\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let dashboardExists = app.navigationBars["Dashboard"].waitForExistence(timeout: 5)
        XCTAssertTrue(dashboardExists)
    }
}
