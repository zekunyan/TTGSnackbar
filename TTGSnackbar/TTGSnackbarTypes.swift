//
//  TTGSnackbarTypes.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

// MARK: - Enum

/**
 Snackbar display duration types.

 - short:   1 second
 - middle:  3 seconds
 - long:    5 seconds
 - forever: Not dismiss automatically. Must be dismissed manually.
 */

@objc public enum TTGSnackbarDuration: Int {
    case short = 1
    case middle = 3
    case long = 5
    case forever = 2147483647 // Must dismiss manually.
    case custom = -1 // Must set customDuration
}

/**
 Snackbar animation types.

 - fadeInFadeOut:               Fade in to show and fade out to dismiss.
 - slideFromBottomToTop:        Slide from the bottom of screen to show and slide up to dismiss.
 - slideFromBottomBackToBottom: Slide from the bottom of screen to show and slide back to bottom to dismiss.
 - slideFromLeftToRight:        Slide from the left to show and slide to rigth to dismiss.
 - slideFromRightToLeft:        Slide from the right to show and slide to left to dismiss.
 - slideFromTopToBottom:        Slide from the top of screen to show and slide down to dismiss.
 - slideFromTopBackToTop:       Slide from the top of screen to show and slide back to top to dismiss.
 */

@objc public enum TTGSnackbarAnimationType: Int {
    case fadeInFadeOut
    case slideFromBottomToTop
    case slideFromBottomBackToBottom
    case slideFromLeftToRight
    case slideFromRightToLeft
    case slideFromTopToBottom
    case slideFromTopBackToTop
}

/// Semantic visual styles for common snackbar states.
@objc public enum TTGSnackbarStyle: Int {
    case `default`
    case info
    case success
    case warning
    case error
    case loading
}

/// Optional haptic feedback to play when the snackbar is shown or interacted with.
@objc public enum TTGSnackbarHapticFeedback: Int {
    case none
    case selection
    case success
    case warning
    case error
    case lightImpact
    case mediumImpact
    case heavyImpact
}

/// Queue behavior used by TTGSnackbarManager.
@objc public enum TTGSnackbarPresentationPolicy: Int {
    /// Show this snackbar after the currently visible snackbar is dismissed.
    case enqueue
    /// Dismiss the visible snackbar and show this one next.
    case replaceCurrent
    /// Ignore this snackbar when a visible or queued snackbar has the same message.
    case dropIfShowingSameMessage
}

/// Result emitted by Swift Concurrency presentation helpers.
public enum TTGSnackbarResult {
    case action
    case secondAction
    case tapped
    case swiped(UISwipeGestureRecognizer.Direction)
    case dismissed
}

/// Value based configuration for modern Swift call sites. Existing property-based APIs remain supported.
public struct TTGSnackbarConfiguration {
    public var message: String
    public var duration: TTGSnackbarDuration
    public var style: TTGSnackbarStyle
    public var actionText: String?
    public var actionBlock: TTGSnackbar.TTGActionBlock?
    public var secondActionText: String?
    public var secondActionBlock: TTGSnackbar.TTGActionBlock?
    public var icon: UIImage?
    public var customDuration: TimeInterval?

    public init(
        message: String,
        duration: TTGSnackbarDuration = .short,
        style: TTGSnackbarStyle = .default,
        actionText: String? = nil,
        actionBlock: TTGSnackbar.TTGActionBlock? = nil,
        secondActionText: String? = nil,
        secondActionBlock: TTGSnackbar.TTGActionBlock? = nil,
        icon: UIImage? = nil,
        customDuration: TimeInterval? = nil
    ) {
        self.message = message
        self.duration = duration
        self.style = style
        self.actionText = actionText
        self.actionBlock = actionBlock
        self.secondActionText = secondActionText
        self.secondActionBlock = secondActionBlock
        self.icon = icon
        self.customDuration = customDuration
    }
}

extension UIColor {
    @objc class open dynamic var ttgDefaultText: UIColor {
        // Meaning it's white in light mode and black in dark mode.
        UIColor.systemBackground
    }

    @objc class open dynamic var ttgDefaultBackground: UIColor {
        // Meaning it's black in light mode and white in dark mode.
        UIColor.label.withAlphaComponent(0.8)
    }

    @objc class open dynamic var ttgDefaultShadow: UIColor {
        // Meaning it's black in light mode and white in dark mode.
        UIColor.label
    }
}

