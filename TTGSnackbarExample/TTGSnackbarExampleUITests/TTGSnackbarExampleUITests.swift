//
//  TTGSnackbarExampleUITests.swift
//  TTGSnackbarExampleUITests
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

import XCTest

final class TTGSnackbarExampleUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testFeatureGalleryLaunchesWithCoreControls() {
        XCTAssertTrue(app.staticTexts["TTGSnackbar Feature Gallery"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["demo.messageField"].exists)
        XCTAssertTrue(app.textFields["demo.actionField"].exists)
        XCTAssertTrue(app.staticTexts["demo.outputLabel"].exists)
        XCTAssertTrue(app.otherElements["demo.customContainer"].exists)
    }

    func testBasicActionAndCallbackDemos() {
        tapDemo("demo.basic-message")
        XCTAssertTrue(app.staticTexts["TTGSnackbar says hello — basic"].waitForExistence(timeout: 2))

        tapDemo("demo.action-button")
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 2))
        app.buttons["Undo"].tap()
        XCTAssertTrue(app.staticTexts["Primary action tapped"].waitForExistence(timeout: 2))
    }

    func testManagerAndCustomContainerDemosAreReachable() {
        tapDemo("demo.custom-container")
        XCTAssertTrue(app.staticTexts["Shown inside a custom container"].waitForExistence(timeout: 2))

        tapDemo("demo.manager-queue")
        XCTAssertTrue(app.staticTexts["Queued 3 snackbars"].waitForExistence(timeout: 2))
    }

    private func tapDemo(_ identifier: String) {
        let button = app.buttons[identifier]
        var attempts = 0
        while !button.exists && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(button.waitForExistence(timeout: 3), "Expected demo button \(identifier) to exist")
        button.tap()
    }
}
