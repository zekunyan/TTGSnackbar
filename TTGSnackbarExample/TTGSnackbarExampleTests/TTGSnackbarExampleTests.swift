//
//  TTGSnackbarExampleTests.swift
//  TTGSnackbarExampleTests
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

import XCTest
@testable import TTGSnackbarExample

final class TTGSnackbarExampleTests: XCTestCase {
    private var hostWindow: UIWindow!

    override func setUp() {
        super.setUp()
        hostWindow = UIWindow(frame: UIScreen.main.bounds)
        hostWindow.rootViewController = UIViewController()
        hostWindow.makeKeyAndVisible()
    }

    override func tearDown() {
        TTGSnackbarManager.shared.dismissAll(animated: false)
        hostWindow.subviews.forEach { $0.removeFromSuperview() }
        hostWindow.isHidden = true
        hostWindow = nil
        super.tearDown()
    }

    func testConfigurationInitializerAppliesValues() {
        let configuration = TTGSnackbarConfiguration(
            message: "Configured message",
            duration: .custom,
            style: .warning,
            actionText: "Retry",
            secondActionText: "Cancel",
            icon: UIImage(systemName: "bell"),
            customDuration: 2.5
        )

        let snackbar = TTGSnackbar(configuration: configuration)

        XCTAssertEqual(snackbar.message, "Configured message")
        XCTAssertEqual(snackbar.duration, .custom)
        XCTAssertEqual(snackbar.customDuration, 2.5)
        XCTAssertEqual(snackbar.actionText, "Retry")
        XCTAssertEqual(snackbar.secondActionText, "Cancel")
        XCTAssertEqual(snackbar.style, .warning)
        XCTAssertNotNil(snackbar.icon)
        XCTAssertEqual(snackbar.hapticFeedback, .warning)
    }

    func testSemanticStylesConfigureRecommendedDefaults() {
        let success = TTGSnackbar(message: "Saved", duration: .short)
        success.style = .success

        XCTAssertEqual(success.style, .success)
        XCTAssertEqual(success.hapticFeedback, .success)
        XCTAssertNotNil(success.icon)
        XCTAssertTrue(success.messageTextColor.isEqual(UIColor.white))

        let loading = TTGSnackbar(message: "Loading", duration: .forever)
        loading.style = .loading

        XCTAssertEqual(loading.style, .loading)
        XCTAssertFalse(loading.activityIndicatorView.isHidden)
        XCTAssertTrue(loading.activityIndicatorView.isAnimating)

        loading.style = .success

        XCTAssertTrue(loading.activityIndicatorView.isHidden)
        XCTAssertFalse(loading.activityIndicatorView.isAnimating)
    }

    func testIconOnlyActionButtonIsVisible() {
        let snackbar = TTGSnackbar(message: "Icon action", duration: .middle)
        snackbar.containerView = hostWindow
        snackbar.actionIcon = UIImage(systemName: "hand.tap")
        snackbar.actionBlock = { _ in }

        snackbar.show()

        XCTAssertFalse(snackbar.actionButton.isHidden)
        XCTAssertEqual(snackbar.actionButton.currentTitle ?? "", "")
        XCTAssertNotNil(snackbar.actionButton.currentImage)
        snackbar.dismiss()
    }

    func testForeverDurationDoesNotScheduleDismissTimer() {
        let snackbar = TTGSnackbar(message: "Manual dismiss", duration: .forever)
        snackbar.containerView = hostWindow

        snackbar.show()

        XCTAssertNil(snackbar.dismissTimer)
        XCTAssertTrue(snackbar.superview === hostWindow)
        snackbar.dismiss()
    }

    func testPauseAndResumeDismissTimerPreservesRemainingTime() {
        let snackbar = TTGSnackbar(message: "Pause timer", duration: .long)
        snackbar.containerView = hostWindow
        snackbar.show()

        XCTAssertNotNil(snackbar.dismissTimer)
        snackbar.pauseDismissTimer()
        XCTAssertNil(snackbar.dismissTimer)
        XCTAssertTrue(snackbar.isDismissTimerPaused)
        XCTAssertNotNil(snackbar.remainingDismissTime)

        snackbar.resumeDismissTimer()
        XCTAssertNotNil(snackbar.dismissTimer)
        XCTAssertFalse(snackbar.isDismissTimerPaused)
        snackbar.dismiss()
    }

    func testManagerDropsDuplicateMessages() {
        let manager = TTGSnackbarManager.shared
        manager.dismissAll(animated: false)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        let first = TTGSnackbar(message: "Duplicate", duration: .forever)
        first.containerView = hostWindow
        let duplicate = TTGSnackbar(message: "Duplicate", duration: .forever)
        duplicate.containerView = hostWindow

        XCTAssertTrue(manager.show(snackbar: first, policy: .dropIfShowingSameMessage))
        XCTAssertFalse(manager.show(snackbar: duplicate, policy: .dropIfShowingSameMessage))
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        XCTAssertTrue(manager.currentSnackbar === first)
        XCTAssertEqual(manager.queuedCount, 0)
        manager.dismissAll(animated: false)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    @MainActor
    func testAsyncPresentationReturnsDroppedWhenManagerDeduplicatesMessage() async {
        let manager = TTGSnackbarManager.shared
        manager.dismissAll(animated: false)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        let first = TTGSnackbar(message: "Async duplicate", duration: .forever)
        first.containerView = hostWindow
        XCTAssertTrue(manager.show(snackbar: first, policy: .dropIfShowingSameMessage))
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        let result = await TTGSnackbar.show(
            configuration: .init(message: "Async duplicate", duration: .short),
            manager: manager,
            policy: .dropIfShowingSameMessage
        )

        if case .dropped = result {
            // Expected path.
        } else {
            XCTFail("Expected duplicate async snackbar to return .dropped, got \(result)")
        }

        manager.dismissAll(animated: false)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    func testMaxWidthAddsAWidthConstraint() {
        let snackbar = TTGSnackbar(message: "Constrained width", duration: .middle)
        snackbar.containerView = hostWindow
        snackbar.snackbarMaxWidth = 200

        XCTAssertTrue(snackbar.show())

        XCTAssertTrue(snackbar.presentationConstraints.contains { constraint in
            constraint.firstItem === snackbar &&
                constraint.firstAttribute == .width &&
                constraint.relation == .lessThanOrEqual &&
                constraint.constant == 200
        })
        snackbar.dismiss()
    }
}
