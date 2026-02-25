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
        app/*@START_MENU_TOKEN@*/.images["dumbbell.fill"]/*[[".buttons[\"Training\"].images",".buttons.images[\"dumbbell.fill\"]",".images[\"dumbbell.fill\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["chevron.right"]/*[[".otherElements",".buttons[\"Forward\"]",".buttons[\"chevron.right\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["chevron.left"]/*[[".otherElements",".buttons[\"Back\"]",".buttons[\"chevron.left\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
    }
    
    // swiftlint:disable:next function_body_length
    func testSignedOutExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        app/*@START_MENU_TOKEN@*/.buttons["Get Started"]/*[[".otherElements.buttons[\"Get Started\"]",".buttons[\"Get Started\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let continueButton = app/*@START_MENU_TOKEN@*/.buttons["Continue"]/*[[".otherElements.buttons[\"Continue\"]",".buttons[\"Continue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Continue with Apple"]/*[[".otherElements.buttons[\"Continue with Apple\"]",".buttons[\"Continue with Apple\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["chevron.right"]/*[[".otherElements[\"chevron.right\"].buttons",".otherElements",".buttons[\"Forward\"]",".buttons[\"chevron.right\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Yearly subscription, $99/year / year, START, This is a yearly subscription description."]/*[[".buttons",".containing(.staticText, identifier: \"This is a yearly subscription description.\")",".containing(.staticText, identifier: \"$99\/year \/ year\")",".containing(.staticText, identifier: \"Yearly subscription\")",".otherElements.buttons[\"Yearly subscription, $99\/year \/ year, START, This is a yearly subscription description.\"]",".buttons[\"Yearly subscription, $99\/year \/ year, START, This is a yearly subscription description.\"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Subscribe"]/*[[".otherElements.buttons[\"Subscribe\"]",".buttons[\"Subscribe\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.textFields["First name"]/*[[".otherElements.textFields[\"First name\"]",".textFields[\"First name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.textFields["First name"]/*[[".otherElements",".textFields[\"Andrew\"]",".textFields[\"First name\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("Andrew")
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Male"]/*[[".buttons.containing(.staticText, identifier: \"Male\")",".otherElements.buttons[\"Male\"]",".buttons[\"Male\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
//        app.buttons["Date Picker"].firstMatch.tap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["February 2008"]/*[[".buttons[\"DatePicker.Show\"].staticTexts",".buttons.staticTexts[\"February 2008\"]",".staticTexts[\"February 2008\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
//        app/*@START_MENU_TOKEN@*/.pickerWheels["2008"]/*[[".pickers.pickerWheels[\"2008\"]",".pickerWheels[\"2008\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.swipeDown()
//        app/*@START_MENU_TOKEN@*/.pickerWheels["February"]/*[[".pickers.pickerWheels[\"February\"]",".pickerWheels[\"February\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.swipeDown()
//        app/*@START_MENU_TOKEN@*/.staticTexts["November 2000"]/*[[".buttons.staticTexts[\"November 2000\"]",".staticTexts",".staticTexts[\"November 2000\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["13"]/*[[".buttons[\"Monday, 13 November\"].staticTexts",".otherElements.staticTexts[\"13\"]",".staticTexts[\"13\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
//        app.windows.element(boundBy: 1).tap()
        continueButton.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.pickerWheels["70 kg"].firstMatch/*[[".pickers.pickerWheels[\"70 kg\"].firstMatch",".pickerWheels",".containing(.other, identifier: nil).firstMatch",".firstMatch",".pickerWheels[\"70 kg\"].firstMatch"],[[[-1,4],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Daily"]/*[[".buttons.containing(.staticText, identifier: \"Daily\")",".otherElements.buttons[\"Daily\"]",".buttons[\"Daily\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Moderate Activity, Regular walking, standing work, daily movement"]/*[[".buttons",".containing(.staticText, identifier: \"Regular walking, standing work, daily movement\")",".containing(.staticText, identifier: \"Moderate Activity\")",".otherElements.buttons[\"Moderate Activity, Regular walking, standing work, daily movement\"]",".buttons[\"Moderate Activity, Regular walking, standing work, daily movement\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Regular cardio, comfortable running, good endurance"]/*[[".buttons.staticTexts[\"Regular cardio, comfortable running, good endurance\"]",".staticTexts[\"Regular cardio, comfortable running, good endurance\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["BMR × (activity + exercise)"]/*[[".otherElements.staticTexts[\"BMR × (activity + exercise)\"]",".staticTexts[\"BMR × (activity + exercise)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Allow access to health data"]/*[[".otherElements.buttons[\"Allow access to health data\"]",".buttons[\"Allow access to health data\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element2 = app/*@START_MENU_TOKEN@*/.switches["I acknowledge and accept the Terms of the Health Disclaimer"].switches["0"].firstMatch/*[[".switches.matching(identifier: \"0\").element(boundBy: 0)",".switches[\"I acknowledge and accept the Terms of the Health Disclaimer\"].switches[\"0\"].firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element2.tap()
        element2.tap()
        app/*@START_MENU_TOKEN@*/.switches["0"]/*[[".switches.switches[\"0\"]",".switches[\"0\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["I Agree & Continue"]/*[[".otherElements.buttons[\"I Agree & Continue\"]",".buttons[\"I Agree & Continue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Lose weight, Goal of losing weight"]/*[[".buttons",".containing(.staticText, identifier: \"Goal of losing weight\")",".containing(.staticText, identifier: \"Lose weight\")",".otherElements.buttons[\"Lose weight, Goal of losing weight\"]",".buttons[\"Lose weight, Goal of losing weight\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.pickerWheels["82 kg"].firstMatch.swipeRight()/*[[".pickers.pickerWheels[\"82 kg\"].firstMatch",".swipeUp()",".swipeRight()",".pickerWheels",".containing(.other, identifier: nil).firstMatch",".firstMatch",".pickerWheels[\"82 kg\"].firstMatch"],[[[-1,6,2],[-1,3,1],[-1,0,2]],[[-1,5,2],[-1,4,2]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.sliders["0.5"]/*[[".otherElements.sliders[\"0.5\"]",".sliders",".sliders[\"0.5\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.swipeRight()
        continueButton.tap()
        continueButton.tap()
        
        let textFieldsQuery = app.textFields
        let element3 = textFieldsQuery.firstMatch
        element3.tap()
        element3.tap()
        app/*@START_MENU_TOKEN@*/.textFields["Platinum Gym Malahide"]/*[[".otherElements.textFields[\"Platinum Gym Malahide\"]",".textFields",".textFields[\"Platinum Gym Malahide\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("Platinum Gym Malahide")
        continueButton.tap()
        continueButton.tap()
        continueButton.tap()
        
        let element4 = app/*@START_MENU_TOKEN@*/.textFields["2026-02-24"]/*[[".otherElements.textFields[\"2026-02-24\"]",".textFields",".textFields[\"2026-02-24\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element4.doubleTap()
        element4.tap()
        element4.tap()
        app/*@START_MENU_TOKEN@*/.textFields["Block 1"]/*[[".otherElements.textFields[\"Block 1\"]",".textFields",".textFields[\"Block 1\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("Block 1")
        continueButton.tap()
        app.buttons.matching(identifier: "flag.pattern.checkered").element(boundBy: 1).tap()
        app/*@START_MENU_TOKEN@*/.buttons["gamecontroller"]/*[[".otherElements.buttons[\"gamecontroller\"]",".buttons[\"gamecontroller\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        
        let element5 = app/*@START_MENU_TOKEN@*/.buttons["plus"]/*[[".cells.buttons",".otherElements",".buttons[\"Add\"]",".buttons[\"plus\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element5.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["A classic compound lift focusing on the pectorals, triceps, and front deltoids."]/*[[".buttons.staticTexts[\"A classic compound lift focusing on the pectorals, triceps, and front deltoids.\"]",".staticTexts[\"A classic compound lift focusing on the pectorals, triceps, and front deltoids.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Pull Up"]/*[[".buttons.staticTexts[\"Pull Up\"]",".staticTexts[\"Pull Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element6 = app/*@START_MENU_TOKEN@*/.staticTexts["Squat"]/*[[".buttons.staticTexts[\"Squat\"]",".staticTexts[\"Squat\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element6.tap()
        
        let element7 = app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".navigationBars.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element7.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Bench Press"]/*[[".buttons.containing(.staticText, identifier: \"Bench Press\")",".otherElements.buttons[\"Bench Press\"]",".buttons[\"Bench Press\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        element5.doubleTap()
        element5.tap()
        
        let optionalElementsQuery = textFieldsQuery.matching(identifier: "Optional")
        let element8 = optionalElementsQuery.element(boundBy: 0)
        element8.tap()
        element8.tap()
        
        let element9 = app/*@START_MENU_TOKEN@*/.textFields["4"]/*[[".otherElements.textFields[\"4\"]",".textFields[\"4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element9.typeText("4")
        
        let element10 = optionalElementsQuery.element(boundBy: 2)
        element10.tap()
        
        let elementsQuery2 = textFieldsQuery.matching(identifier: "4")
        let element11 = elementsQuery2.element(boundBy: 1)
        element11.typeText("4")
        element11.tap()
        
        let element12 = optionalElementsQuery.element(boundBy: 4)
        element12.tap()
        element12.typeText("4")
        element12.tap()
        
        let element13 = optionalElementsQuery.element(boundBy: 6)
        element13.tap()
        element11.typeText("4")
        element12.tap()
        element11.typeText("4")
        element11.tap()
        app/*@START_MENU_TOKEN@*/.textFields["44"]/*[[".otherElements.textFields[\"44\"]",".textFields[\"44\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        element11.typeKey(.delete, modifierFlags:[])
        
        let element14 = optionalElementsQuery.element(boundBy: 1)
        element14.doubleTap()
        element14.tap()
        
        let element15 = app/*@START_MENU_TOKEN@*/.textFields["6"]/*[[".otherElements.textFields[\"6\"]",".textFields[\"6\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element15.typeText("6")
        
        let element16 = optionalElementsQuery.element(boundBy: 3)
        element16.tap()
        
        let elementsQuery3 = textFieldsQuery.matching(identifier: "6")
        let element17 = elementsQuery3.element(boundBy: 1)
        element17.typeText("6")
        element17.tap()
        
        let element18 = optionalElementsQuery.element(boundBy: 5)
        element18.tap()
        
        let element19 = elementsQuery3.element(boundBy: 2)
        element19.typeText("6")
        element19.tap()
        
        let element20 = optionalElementsQuery.element(boundBy: 7)
        element20.tap()
        
        let element21 = elementsQuery3.element(boundBy: 3)
        element21.typeText("6")
        element21.tap()
        element7.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Pull Up"]/*[[".buttons.containing(.staticText, identifier: \"Pull Up\")",".otherElements.buttons[\"Pull Up\"]",".buttons[\"Pull Up\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        element5.doubleTap()
        element5.tap()
        element8.tap()
        
        let element22 = app/*@START_MENU_TOKEN@*/.textFields["8"]/*[[".otherElements.textFields[\"8\"]",".textFields[\"8\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element22.typeText("8")
        element10.tap()
        
        let elementsQuery4 = textFieldsQuery.matching(identifier: "8")
        let element23 = elementsQuery4.element(boundBy: 1)
        element23.typeText("8")
        element23.tap()
        element12.tap()
        
        let element24 = elementsQuery4.element(boundBy: 2)
        element24.typeText("8")
        element13.tap()
        
        let element25 = elementsQuery4.element(boundBy: 3)
        element25.tap()
        element25.typeText("8")
        element25.tap()
        element14.tap()
        app/*@START_MENU_TOKEN@*/.textFields["12"]/*[[".otherElements.textFields[\"12\"]",".textFields[\"12\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("12")
        element16.tap()
        
        let elementsQuery5 = textFieldsQuery.matching(identifier: "12")
        let element26 = elementsQuery5.element(boundBy: 1)
        element26.typeText("12")
        element26.tap()
        element18.tap()
        
        let element27 = elementsQuery5.element(boundBy: 2)
        element27.typeText("12")
        element27.tap()
        element20.tap()
        elementsQuery5.element(boundBy: 3).typeText("12")
        element7.tap()
        element6.tap()
        element8.tap()
        element8.tap()
        element15.typeText("6")
        element5.tap()
        element10.tap()
        element17.typeText("6")
        element17.tap()
        element5.tap()
        element12.tap()
        element19.typeText("6")
        element19.tap()
        element5.tap()
        element13.tap()
        element21.typeText("6")
        element21.tap()
        element14.tap()
        element14.tap()
        element22.typeText("8")
        element16.tap()
        element23.typeText("8")
        element23.tap()
        element18.tap()
        element24.typeText("8")
        element24.tap()
        element20.tap()
        element25.typeText("8")
        element25.tap()
        element7.tap()
        
        let element28 = app/*@START_MENU_TOKEN@*/.staticTexts["Add Day"]/*[[".buttons[\"Add Day\"].staticTexts",".buttons.staticTexts[\"Add Day\"]",".staticTexts[\"Add Day\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element28.tap()
        element5.tap()
        
        let element29 = app/*@START_MENU_TOKEN@*/.staticTexts["Overhead Press"]/*[[".buttons.staticTexts[\"Overhead Press\"]",".staticTexts[\"Overhead Press\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element29.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Bulgarian Split Squat, A single-leg lower body movement for quads and glutes, performed with the back foot elevated."]/*[[".buttons",".containing(.staticText, identifier: \"A single-leg lower body movement for quads and glutes, performed with the back foot elevated.\")",".containing(.staticText, identifier: \"Bulgarian Split Squat\")",".otherElements.buttons[\"Bulgarian Split Squat, A single-leg lower body movement for quads and glutes, performed with the back foot elevated.\"]",".buttons[\"Bulgarian Split Squat, A single-leg lower body movement for quads and glutes, performed with the back foot elevated.\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["A single-leg lower body movement for quads and glutes, performed with the back foot elevated."].firstMatch.swipeRight()/*[[".buttons.staticTexts[\"A single-leg lower body movement for quads and glutes, performed with the back foot elevated.\"].firstMatch",".swipeUp()",".swipeRight()",".staticTexts[\"A single-leg lower body movement for quads and glutes, performed with the back foot elevated.\"].firstMatch"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        
        let element30 = app/*@START_MENU_TOKEN@*/.staticTexts["Push Up"]/*[[".buttons.staticTexts[\"Push Up\"]",".staticTexts[\"Push Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element30.tap()
        element7.tap()
        element29.tap()
        element5.doubleTap()
        element5.tap()
        element8.tap()
        element8.tap()
        element9.typeText("4")
        element10.tap()
        element11.typeText("4")
        element12.tap()
        
        let element31 = elementsQuery2.element(boundBy: 2)
        element31.tap()
        element31.typeText("4")
        element31.tap()
        element13.tap()
        
        let element32 = elementsQuery2.element(boundBy: 3)
        element32.typeText("4")
        element14.tap()
        element14.tap()
        element15.typeText("6")
        element16.tap()
        element17.typeText("6")
        element17.tap()
        element18.tap()
        element19.typeText("6")
        element19.tap()
        element20.tap()
        element21.typeText("6")
        element7.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Bulgarian Split Squat"]/*[[".buttons.staticTexts[\"Bulgarian Split Squat\"]",".staticTexts[\"Bulgarian Split Squat\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        element5.doubleTap()
        element5.tap()
        element8.tap()
        element8.tap()
        element9.typeText("4")
        element10.tap()
        element10.tap()
        element11.typeText("4")
        element12.tap()
        element12.tap()
        element31.typeText("4")
        element13.tap()
        element32.typeText("4")
        element32.tap()
        element14.tap()
        element15.typeText("6")
        element16.tap()
        element17.typeText("6")
        element17.tap()
        element18.tap()
        element19.typeText("6")
        element20.tap()
        element21.typeText("6")
        element21.tap()
        element7.tap()
        element30.tap()
        element5.doubleTap()
        element5.tap()
        element8.tap()
        element22.typeText("8")
        element10.tap()
        element10.tap()
        element23.typeText("8")
        element12.tap()
        element12.tap()
        element24.typeText("8")
        element13.tap()
        element25.typeText("8")
        element25.tap()
        element14.tap()
        app/*@START_MENU_TOKEN@*/.textFields["10"]/*[[".otherElements.textFields[\"10\"]",".textFields[\"10\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("10")
        element16.tap()
        element16.tap()
        app/*@START_MENU_TOKEN@*/.textFields["20"]/*[[".otherElements.textFields[\"20\"]",".textFields[\"20\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("202")
        element18.tap()
        element18.tap()
        
        let elementsQuery = textFieldsQuery.matching(identifier: "10")
        elementsQuery.element(boundBy: 1).typeText("10")
        element20.tap()
        element20.tap()
        elementsQuery.element(boundBy: 2).typeText("10")
        element7.tap()
        element28.tap()
        element28.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Activate Program"]/*[[".otherElements.buttons[\"Activate Program\"]",".buttons[\"Activate Program\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Standard distribution of carbs and fat."]/*[[".buttons.staticTexts[\"Standard distribution of carbs and fat.\"]",".staticTexts[\"Standard distribution of carbs and fat.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Your recommendations will never go below 1200 calories per day, even if your TDEE is lower."]/*[[".otherElements.staticTexts[\"Your recommendations will never go below 1200 calories per day, even if your TDEE is lower.\"]",".staticTexts[\"Your recommendations will never go below 1200 calories per day, even if your TDEE is lower.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Distribute calories evenly across all days of the week."]/*[[".buttons.staticTexts[\"Distribute calories evenly across all days of the week.\"]",".staticTexts[\"Distribute calories evenly across all days of the week.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        continueButton.tap()
        app.cells/*@START_MENU_TOKEN@*/.containing(.staticText, identifier: "Moderate").firstMatch/*[[".element(boundBy: 1)",".containing(.staticText, identifier: \"In the middle of the optimal range.\").firstMatch",".containing(.staticText, identifier: \"Moderate\").firstMatch"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        continueButton.tap()
        app.staticTexts.matching(identifier: "Protein").element(boundBy: 1).tap()
        continueButton.tap()
        
        let dashboardExists = app.navigationBars["Dashboard"].waitForExistence(timeout: 5)
        XCTAssertTrue(dashboardExists)
    }
}
