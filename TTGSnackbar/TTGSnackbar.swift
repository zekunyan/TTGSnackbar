//
//  TTGSnackbar.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit
import Darwin

// MARK: -
// MARK: Enum

/**
Snackbar display duration types.

- Short:   1 second
- Middle:  3 seconds
- Long:    5 seconds
- Forever: Not dismiss automatically. Must be dismissed manually.
*/

public enum TTGSnackbarDuration: NSTimeInterval {
    case Short = 1.0
    case Middle = 3.0
    case Long = 5.0
    case Forever = 9999999999.0 // Must dismiss manually.
}

/**
Snackbar animation types.

- FadeInFadeOut:               Fade in to show and fade out to dismiss.
- SlideFromBottomToTop:        Slide from the bottom of screen to show and slide up to dismiss.
- SlideFromBottomBackToBottom: Slide from the bottom of screen to show and slide back to bottom to dismiss.
- SlideFromLeftToRight:        Slide from the left to show and slide to rigth to dismiss.
- SlideFromRightToLeft:        Slide from the right to show and slide to left to dismiss.
- Flip:                        Flip to show and dismiss.
*/

public enum TTGSnackbarAnimationType {
    case FadeInFadeOut
    case SlideFromBottomToTop
    case SlideFromBottomBackToBottom
    case SlideFromLeftToRight
    case SlideFromRightToLeft
    case Flip
}

public class TTGSnackbar: UIView {
    // MARK: -
    // MARK: Class property.

    /// Snackbar action button width.
    private static let snackbarActionButtonWidth: CGFloat = 64

    /// Snackbar horizon margin
    private static let snackbarHorizonMargin: CGFloat = 4

    // MARK: -
    // MARK: Typealias

    /// Action callback closure definition.
    public typealias TTGActionBlock = (snackbar:TTGSnackbar) -> Void

    /// Dismiss callback closure definition.
    public typealias TTGDismissBlock = (snackbar:TTGSnackbar) -> Void

    // MARK: -
    // MARK: Public property.

    /// Action callback.
    public var actionBlock: TTGActionBlock? = nil

    /// Dismiss callback.
    public var dismissBlock: TTGDismissBlock? = nil

    /// Snackbar display duration. Default is Short - 1 second.
    public var duration: TTGSnackbarDuration = TTGSnackbarDuration.Short

    /// Snackbar animation type. Default is SlideFromBottomBackToBottom.
    public var animationType: TTGSnackbarAnimationType = TTGSnackbarAnimationType.SlideFromBottomBackToBottom

    /// Show and hide animation duration
    public var animationDuration: NSTimeInterval = 0.3

    /// Corner radius: [0, height / 2]
    public var cornerRadius: CGFloat = 4 {
        didSet {
            if cornerRadius > height / 2 {
                cornerRadius = height / 2
            }

            if cornerRadius < 0 {
                cornerRadius = 0
            }

            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }

    /// Left margin
    public var leftMargin: CGFloat = 4 {
        didSet {
            leftMarginConstraint?.constant = leftMargin
            self.layoutIfNeeded()
        }
    }

    /// Right margin
    public var rightMargin: CGFloat = 4 {
        didSet {
            rightMarginConstraint?.constant = -rightMargin
            self.layoutIfNeeded()
        }
    }

    /// Bottom margin
    public var bottomMargin: CGFloat = 4 {
        didSet {
            bottomMarginConstraint?.constant = -bottomMargin
            self.layoutIfNeeded()
        }
    }

    /// Height: [44, +]
    public var height: CGFloat = 44 {
        didSet {
            if height < 44 {
                height = 44
            }
        }
    }

    /// Main text shown on the snackbar.
    public var message: String = "" {
        didSet {
            self.messageLabel.text = message
        }
    }

    /// Message text color. Default is white.
    public dynamic var messageTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.messageLabel.textColor = messageTextColor
        }
    }

    /// Message text font. Default is Bold system font (14).
    public dynamic var messageTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            self.messageLabel.font = messageTextFont
        }
    }

    /// Message text alignment. Default is left
    public dynamic var messageTextAlign: NSTextAlignment = .Left {
        didSet {
            self.messageLabel.textAlignment = messageTextAlign
        }
    }

    /// Action button title.
    public dynamic var actionText: String = "" {
        didSet {
            self.actionButton.setTitle(actionText, forState: UIControlState.Normal)
        }
    }

    /// Action button title color. Default is white.
    public dynamic var actionTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            actionButton.setTitleColor(actionTextColor, forState: UIControlState.Normal)
        }
    }

    /// Action text font. Default is Bold system font (14).
    public dynamic var actionTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            self.actionButton.titleLabel?.font = actionTextFont
        }
    }

    // MARK: -
    // MARK: Private property.

    private var messageLabel: UILabel!
    private var seperateView: UIView!
    private var actionButton: UIButton!
    private var activityIndicatorView: UIActivityIndicatorView!

    /// Timer to dismiss the snackbar.
    private var dismissTimer: NSTimer? = nil

    // Constraints.
    private var leftMarginConstraint: NSLayoutConstraint? = nil
    private var rightMarginConstraint: NSLayoutConstraint? = nil
    private var bottomMarginConstraint: NSLayoutConstraint? = nil
    private var actionButtonWidthConstraint: NSLayoutConstraint? = nil

    // MARK: -
    // MARK: Init

    /**
    Show a single message like a Toast.
    
    - parameter message:  Message text.
    - parameter duration: Duration type.
    
    - returns: Void
    */
    public init(message: String, duration: TTGSnackbarDuration) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        self.duration = duration
        self.message = message
        configure()
    }

    /**
    Show a message with action button.
    
    - parameter message:     Message text.
    - parameter duration:    Duration type.
    - parameter actionText:  Action button title.
    - parameter actionBlock: Action callback closure.
    
    - returns: Void
    */
    public init(message: String, duration: TTGSnackbarDuration, actionText: String, actionBlock: TTGActionBlock) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        self.duration = duration
        self.message = message
        self.actionText = actionText
        self.actionBlock = actionBlock
        configure()
    }

    /**
    Show a custom message with action button.
     
    - parameter message:          Message text.
    - parameter duration:         Duration type.
    - parameter actionText:       Action button title.
    - parameter messageFont:      Message label font.
    - parameter actionButtonFont: Action button font.
    - parameter actionBlock:      Action callback closure.

    - returns: Void
    */
    public init(message: String, duration: TTGSnackbarDuration, actionText: String, messageFont: UIFont, actionTextFont: UIFont, actionBlock: TTGActionBlock) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        self.duration = duration
        self.message = message
        self.actionText = actionText
        self.actionBlock = actionBlock
        self.messageTextFont = messageFont
        self.actionTextFont = actionTextFont
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -
    // MARK: Public methods.

    /**
    Show the snackbar.
    */
    public func show() {
        // Only show once
        if self.superview != nil {
            return
        }

        // Create dismiss timer
        dismissTimer = NSTimer.scheduledTimerWithTimeInterval(duration.rawValue, target: self, selector: "dismiss", userInfo: nil, repeats: false)

        // Show or hide action button
        actionButton.hidden = actionText.isEmpty || actionBlock == nil
        seperateView.hidden = actionButton.hidden
        actionButtonWidthConstraint?.constant = actionButton.hidden ? 0 : TTGSnackbar.snackbarActionButtonWidth

        // Find current stop viewcontroller
        if let topController = getTopViewController() {
            let superView: UIView = topController.view
            superView.addSubview(self)

            // Snackbar height constraint
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self, attribute: .Height,
                    relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)

            // Left margin constraint
            leftMarginConstraint = NSLayoutConstraint.init(item: self, attribute: .Left,
                    relatedBy: .Equal, toItem: superView, attribute: .Left, multiplier: 1, constant: leftMargin)

            // Right margin constraint
            rightMarginConstraint = NSLayoutConstraint.init(item: self, attribute: .Right,
                    relatedBy: .Equal, toItem: superView, attribute: .Right, multiplier: 1, constant: -rightMargin)

            // Bottom margin constraint
            bottomMarginConstraint = NSLayoutConstraint.init(item: self, attribute: .Bottom,
                    relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: -bottomMargin)

            // Avoid the "UIView-Encapsulated-Layout-Height" constraint conflicts
            // http://stackoverflow.com/questions/25059443/what-is-nslayoutconstraint-uiview-encapsulated-layout-height-and-how-should-i
            leftMarginConstraint?.priority = 999
            rightMarginConstraint?.priority = 999

            // Add constraints
            self.addConstraint(heightConstraint)
            superView.addConstraint(leftMarginConstraint!)
            superView.addConstraint(rightMarginConstraint!)
            superView.addConstraint(bottomMarginConstraint!)

            // Show 
            showWithAnimation()
        }
    }

    /**
    Dismiss the snackbar manually.
    */
    public func dismiss() {
        // On main thread
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.dismissAnimated(true)
        }
    }

    // MARK: -
    // MARK: Private methods.

    /**
    Init configuration.
    */
    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.font = messageTextFont
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.lineBreakMode = .ByCharWrapping
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .Left
        messageLabel.text = message
        self.addSubview(messageLabel)

        actionButton = UIButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = UIColor.clearColor()
        actionButton.titleLabel?.font = actionTextFont
        actionButton.setTitle(actionText, forState: .Normal)
        actionButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        actionButton.addTarget(self, action: Selector("doAction"), forControlEvents: .TouchUpInside)
        self.addSubview(actionButton)

        seperateView = UIView()
        seperateView.translatesAutoresizingMaskIntoConstraints = false
        seperateView.backgroundColor = UIColor.grayColor()
        self.addSubview(seperateView)

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.stopAnimating()
        self.addSubview(activityIndicatorView)

        // Add constraints
        let hConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "H:|-snackbarHorizonMargin-[messageLabel]-[seperateView(1)]-[actionButton]-snackbarHorizonMargin-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: ["snackbarHorizonMargin": TTGSnackbar.snackbarHorizonMargin],
                views: ["messageLabel": messageLabel, "seperateView": seperateView, "actionButton": actionButton])

        let vConstraintsForMessageLabel: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-[messageLabel]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["messageLabel": messageLabel])

        let vConstraintsForSeperateView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-[seperateView]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["seperateView": seperateView])

        let vConstraintsForActionButton: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-[actionButton]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["actionButton": actionButton])

        actionButtonWidthConstraint = NSLayoutConstraint.init(
        item: actionButton, attribute: .Width, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarActionButtonWidth)

        let vConstraintsForActivityIndicatorView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-(2)-[activityIndicatorView]-(2)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["activityIndicatorView": activityIndicatorView])

        let hConstraintsForActivityIndicatorView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "H:[activityIndicatorView(activityIndicatorWidth)]-(2)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: ["activityIndicatorWidth": height - 4],
                views: ["activityIndicatorView": activityIndicatorView])

        self.addConstraints(hConstraints)
        self.addConstraints(vConstraintsForMessageLabel)
        self.addConstraints(vConstraintsForSeperateView)
        self.addConstraints(vConstraintsForActionButton)
        self.addConstraints(vConstraintsForActivityIndicatorView)
        self.addConstraints(hConstraintsForActivityIndicatorView)
        actionButton.addConstraint(actionButtonWidthConstraint!)
    }

    /**
    Invalid the dismiss timer.
    */
    private func invalidDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }

    /**
    Get the current top viewController.
    
    - returns: current top viewController instance or nil.
    */
    private func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }

    /**
    Dismiss.
    
    - parameter animated: If dismiss with animation.
    */
    private func dismissAnimated(animated: Bool) {
        invalidDismissTimer()
        activityIndicatorView.stopAnimating()

        let superViewWidth = CGRectGetWidth((superview?.frame)!)

        if !animated {
            dismissBlock?(snackbar: self)
            self.removeFromSuperview()
            return
        }

        var animationBlock: (() -> Void)? = nil

        switch animationType {
        case .FadeInFadeOut:
            animationBlock = {
                self.alpha = 0.0
            }
        case .SlideFromBottomBackToBottom:
            bottomMarginConstraint?.constant = height
        case .SlideFromBottomToTop:
            animationBlock = {
                self.alpha = 0.0
            }
            bottomMarginConstraint?.constant = -height - bottomMargin
        case .SlideFromLeftToRight:
            leftMarginConstraint?.constant = leftMargin + superViewWidth
            rightMarginConstraint?.constant = -rightMargin + superViewWidth
        case .SlideFromRightToLeft:
            leftMarginConstraint?.constant = leftMargin - superViewWidth
            rightMarginConstraint?.constant = -rightMargin - superViewWidth
        case .Flip:
            animationBlock = {
                self.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 1, 0, 0)
            }
        }

        self.setNeedsLayout()
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: .CurveEaseIn,
                animations: {
                    () -> Void in
                    animationBlock?()
                    self.layoutIfNeeded()
                }) {
            (finished) -> Void in
            self.dismissBlock?(snackbar: self)
            self.removeFromSuperview()
        }
    }

    /**
    Show.
    */
    private func showWithAnimation() {
        var animationBlock: (() -> Void)? = nil
        let superViewWidth = CGRectGetWidth((superview?.frame)!)

        switch animationType {
        case .FadeInFadeOut:
            self.alpha = 0.0
            self.layoutIfNeeded()
            // Animation
            animationBlock = {
                self.alpha = 1.0
            }
        case .SlideFromBottomBackToBottom, .SlideFromBottomToTop:
            bottomMarginConstraint?.constant = height
            self.layoutIfNeeded()
        case .SlideFromLeftToRight:
            leftMarginConstraint?.constant = leftMargin - superViewWidth
            rightMarginConstraint?.constant = -rightMargin - superViewWidth
            bottomMarginConstraint?.constant = -bottomMargin
            self.layoutIfNeeded()
        case .SlideFromRightToLeft:
            leftMarginConstraint?.constant = leftMargin + superViewWidth
            rightMarginConstraint?.constant = -rightMargin + superViewWidth
            bottomMarginConstraint?.constant = -bottomMargin
            self.layoutIfNeeded()
        case .Flip:
            self.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 1, 0, 0)
            self.layoutIfNeeded()
            // Animation
            animationBlock = {
                self.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
            }
        }

        // Final state
        bottomMarginConstraint?.constant = -bottomMargin
        leftMarginConstraint?.constant = leftMargin
        rightMarginConstraint?.constant = -rightMargin

        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .CurveEaseInOut,
                animations: {
                    () -> Void in
                    animationBlock?()
                    self.layoutIfNeeded()
                }, completion: nil)
    }

    /**
    Action button.
    */
    func doAction() {
        // Call action block first
        actionBlock?(snackbar: self)

        // Show activity indicator
        if duration == .Forever && actionButton.hidden == false {
            actionButton.hidden = true
            seperateView.hidden = true
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
        } else {
            dismissAnimated(true)
        }
    }
}
