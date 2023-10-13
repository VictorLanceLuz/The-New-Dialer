//
//  TheNewDialerUITests.swift
//  TheNewDialerUITests
//
//  Created by empark on 2019-11-15.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//

import XCTest

class TheNewDialerUITests: XCTestCase {
    
    // manually change this for different hold increment values
    // incorrect values may yield incorrect test failures
    let holdDuration = 0.5;
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDialerButtonHold() {
        // Test button hold of the dialer, ensure proper values are entered
        let app = XCUIApplication()
        let dialerimageButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .button).element(boundBy: 1)
        let deleteButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element
        
        // Increment through all numbers, enter number 5 times, and erase 5 times
        for index in 1...10
        {
            let duration = holdDuration * Double(index);
            var dialNum = String(index);
            dialNum += dialNum + dialNum + dialNum + dialNum;
            if index == 10
            {
                dialNum = "00000";
            }
            
            // Test using different variations in duration
            dialerimageButton.press(forDuration: duration + 0.1);
            dialerimageButton.press(forDuration: duration + 0.01);
            dialerimageButton.press(forDuration: duration + 0.001);
            dialerimageButton.press(forDuration: duration + 0.0005);
            dialerimageButton.press(forDuration: duration + 0.4995);
            
            XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, dialNum, "Number entry failed");
            
            // Remove entered number
            deleteButton.tap(withNumberOfTaps: 5, numberOfTouches: 1)
            
            XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "Tap number to remove digit", "Number erase failed");
            
        }
    }
    
    // test dialer contact suggestions using iOS simulator contacts
    func testDialSuggestions() {
        
        let holdTime = holdDuration + 0.01
        let app = XCUIApplication()
        let dialerimageButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .button).element(boundBy: 1)
        let callimageButton = app.buttons["callImage"]
        let john = app.descendants(matching: .table).element.staticTexts["John Appleseed"]
        let kate = app.descendants(matching: .table).element.staticTexts["Kate Bell"]
        let deleteButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element
        
        // Enter 888, only contact that should appear is John
        dialerimageButton.press(forDuration: holdTime * 8);
        dialerimageButton.press(forDuration: holdTime * 8);
        dialerimageButton.press(forDuration: holdTime * 8);
        
        john.tap()
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "8885555512", "John's number is incorrect or unavailable");
        
        callimageButton.press(forDuration: 2.2);
        
        deleteButton.tap(withNumberOfTaps: 10, numberOfTouches: 1)
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "Tap number to remove digit", "Number erase unsuccessful");
        
        // Enter 555564, only contact that should appear is Kate
        dialerimageButton.press(forDuration: holdTime * 5);
        dialerimageButton.press(forDuration: holdTime * 5);
        dialerimageButton.press(forDuration: holdTime * 5);
        dialerimageButton.press(forDuration: holdTime * 5);
        dialerimageButton.press(forDuration: holdTime * 6);
        dialerimageButton.press(forDuration: holdTime * 4);
        
        kate.tap()
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "5555648583", "Kate's number is incorrect or unavailable");
        
        // Switch between tabs and ensure number is preserved after
        app.tabBars.buttons["Contacts"].tap()
        app.tabBars.buttons["Dialer"].tap()
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "5555648583", "Kate's number is altered after switching tabs");
        
        callimageButton.press(forDuration: 2.2);
        
        deleteButton.tap(withNumberOfTaps: 10, numberOfTouches: 1)
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "Tap number to remove digit", "Number erase unsuccessful");
    }
    
    // test calling from Contacts menu as well as preserving entered number in Dialer screen
    func testContacts() {
        
        let holdTime = holdDuration + 0.01
        let app = XCUIApplication()
        let dialerimageButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .button).element(boundBy: 1)
        let callimageButton = app.buttons["callImage"]
        
        dialerimageButton.press(forDuration: holdTime * 1);
        dialerimageButton.press(forDuration: holdTime * 2);
        dialerimageButton.press(forDuration: holdTime * 3);
        
        // switch to contacts tab and call contact
        app.tabBars.buttons["Contacts"].tap()
        app.tables.staticTexts["David Taylor"].press(forDuration: 1.0);
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
        
        app.tabBars.buttons["Dialer"].tap()
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "123", "Entered number not saved after switching tabs");
        
        app.tabBars.buttons["Contacts"].tap()
        app.tables.staticTexts["Anna Haro"].press(forDuration: 1.0);
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
        
        app.tabBars.buttons["Contacts"].tap()
        app.tables.staticTexts["Daniel Higgins"].press(forDuration: 1.0);
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
    }
    
    
    // test Emergency contacts feature
    // REQURIES REMOVING OF APP DATA BEFORE TEST
    func testEnergency() {
        
        let duration = holdDuration + 0.01
        
        let app = XCUIApplication()
        let dialerimageButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .button).element(boundBy: 1)
        let emergencyButton = app.tabBars.buttons["Emergency"]
        let dialerButton = app.tabBars.buttons["Dialer"]
        
        
        dialerimageButton.press(forDuration: duration + 0.1);
        dialerimageButton.press(forDuration: duration + 0.1);
        dialerimageButton.press(forDuration: duration + 0.1);
        
        emergencyButton.tap()
        app.buttons["Add Contact #1"].tap()
        app.tables["ContactsListView"].staticTexts["John Appleseed"].tap()
        
        dialerButton.tap()
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "111", "Entered number not saved");
        
        emergencyButton.tap()
        app.buttons["John"].tap()
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
        
        app.buttons["Add contact #2"].tap()
        app.tables["ContactsListView"].staticTexts["Kate Bell"].tap()
        app.buttons["Kate"].tap()
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
        
        app.buttons["911"].tap()
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
        
    }
    
    // test call history feature
    // REQUIRES REMOVING OF APP DATA BEFORE TEST
    func testCallHistory() {
        
        let duration = holdDuration + 0.01
        
        let app = XCUIApplication()
        let dialerimageButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .button).element(boundBy: 1)
        let deleteButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element
        let historyButton = app.tabBars.buttons["Call History"]
        let dialerButton = app.tabBars.buttons["Dialer"]
        let callimageButton = app.buttons["callImage"]
        
        dialerimageButton.press(forDuration: duration + 0.1);
        dialerimageButton.press(forDuration: duration + 0.1);
        dialerimageButton.press(forDuration: duration + 0.1);
        
        historyButton.tap()
        dialerButton.tap()
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "111", "Entered number not saved");
        
        deleteButton.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        
        dialerimageButton.press(forDuration: duration + 0.1);
        
        app.tables.staticTexts["John Appleseed"].tap();
        
        callimageButton.press(forDuration: 2.1);
        
        historyButton.tap()
        
        app.navigationBars["Call History"].buttons["Refresh"].tap()
        
        app.tables.children(matching: .cell).element(boundBy: 1).staticTexts["888-555-5512"].tap()
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
        
    }
    
    //deprecated
    /*
    func testExample() {
        // Use recording to get started writing UI tests.
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        let dialerimageButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .button).element(boundBy: 1)
        // test holding the dialer button
        // hardcoded hold values for entering 1234567890
        dialerimageButton.press(forDuration: 0.26);
        dialerimageButton.press(forDuration: 0.65);
        dialerimageButton.press(forDuration: 0.755);
        dialerimageButton.press(forDuration: 1.15);
        dialerimageButton.press(forDuration: 1.31);
        dialerimageButton.press(forDuration: 1.6);
        dialerimageButton.press(forDuration: 1.99);
        dialerimageButton.press(forDuration: 2.01);
        dialerimageButton.press(forDuration: 2.35);
        dialerimageButton.press(forDuration: 2.55);
        
        // check that entered number is matching
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "0112233445")
        
        // erase previously entered numbers
        let button = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element
        
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        
        XCTAssertEqual(app.descendants(matching: .textField).element.value as! String, "0112")
        
        // switch to contacts tab and call contact
        app.tabBars.buttons["Contacts"].tap()
        app.tables.staticTexts["David Taylor"].press(forDuration: 1.0);
        app.alerts["Invalid Phone Number"].buttons["OK"].tap()
        
    }
    */
    
}

