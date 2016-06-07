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

@objc public enum TTGSnackbarDuration: Int {
    case Short = 1
    case Middle = 3
    case Long = 5
    case Forever = 2147483647 // Must dismiss manually.
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

@objc public enum TTGSnackbarAnimationType: Int {
    case FadeInFadeOut
    case SlideFromBottomToTop
    case SlideFromBottomBackToBottom
    case SlideFromLeftToRight
    case SlideFromRightToLeft
}

public class TTGSnackbar: UIView {
    // MARK: -
    // MARK: Class property.

    /// Snackbar default frame
    private static let snackbarDefaultFrame: CGRect = CGRectMake(0, 0, 320, 44)

    /// Snackbar action button max width.
    private static let snackbarActionButtonMaxWidth: CGFloat = 64

    /// Snackbar action button min width.
    private static let snackbarActionButtonMinWidth: CGFloat = 44

    /// Snackbar icon imageView default width
    private static let snackbarIconImageViewWidth: CGFloat = 32

    // MARK: -
    // MARK: Typealias

    /// Action callback closure definition.
    public typealias TTGActionBlock = (snackbar:TTGSnackbar) -> Void

    /// Dismiss callback closure definition.
    public typealias TTGDismissBlock = (snackbar:TTGSnackbar) -> Void

    // MARK: -
    // MARK: Public property.

    /// Action callback.
    public dynamic var actionBlock: TTGActionBlock? = nil

    /// Second action block
    public dynamic var secondActionBlock: TTGActionBlock? = nil

    /// Dismiss callback.
    public dynamic var dismissBlock: TTGDismissBlock? = nil

    /// Snackbar display duration. Default is Short - 1 second.
    public dynamic var duration: TTGSnackbarDuration = TTGSnackbarDuration.Short

    /// Snackbar animation type. Default is SlideFromBottomBackToBottom.
    public dynamic var animationType: TTGSnackbarAnimationType = TTGSnackbarAnimationType.SlideFromBottomBackToBottom

    /// Show and hide animation duration. Default is 0.3
    public dynamic var animationDuration: NSTimeInterval = 0.3

    /// Corner radius: [0, height / 2]. Default is 4
    public dynamic var cornerRadius: CGFloat = 4 {
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

    /// Left margin. Default is 4
    public dynamic var leftMargin: CGFloat = 4 {
        didSet {
            leftMarginConstraint?.constant = leftMargin
            self.layoutIfNeeded()
        }
    }

    /// Right margin. Default is 4
    public dynamic var rightMargin: CGFloat = 4 {
        didSet {
            rightMarginConstraint?.constant = -rightMargin
            self.layoutIfNeeded()
        }
    }

    /// Bottom margin. Default is 4
    public dynamic var bottomMargin: CGFloat = 4 {
        didSet {
            bottomMarginConstraint?.constant = -bottomMargin
            self.layoutIfNeeded()
        }
    }

    /// Height: [44, +]. Default is 44
    public dynamic var height: CGFloat = 44 {
        didSet {
            if height < 44 {
                height = 44
            }
            heightConstraint?.constant = height
            self.layoutIfNeeded()
        }
    }

    /// Main text shown on the snackbar.
    public dynamic var message: String = "" {
        didSet {
            messageLabel.text = message
        }
    }

    /// Message text color. Default is white.
    public dynamic var messageTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            messageLabel.textColor = messageTextColor
        }
    }

    /// Message text font. Default is Bold system font (14).
    public dynamic var messageTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            messageLabel.font = messageTextFont
        }
    }

    /// Message text alignment. Default is left
    public dynamic var messageTextAlign: NSTextAlignment = .Left {
        didSet {
            messageLabel.textAlignment = messageTextAlign
        }
    }

    /// Action button title.
    public dynamic var actionText: String = "" {
        didSet {
            actionButton.setTitle(actionText, forState: UIControlState.Normal)
        }
    }

    /// Second action button title.
    public dynamic var secondActionText: String = "" {
        didSet {
            secondActionButton.setTitle(secondActionText, forState: UIControlState.Normal)
        }
    }

    /// Action button title color. Default is white.
    public dynamic var actionTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            actionButton.setTitleColor(actionTextColor, forState: UIControlState.Normal)
        }
    }

    /// Second action button title color. Default is white.
    public dynamic var secondActionTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            secondActionButton.setTitleColor(secondActionTextColor, forState: UIControlState.Normal)
        }
    }

    /// Action text font. Default is Bold system font (14).
    public dynamic var actionTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            actionButton.titleLabel?.font = actionTextFont
        }
    }

    /// Second action text font. Default is Bold system font (14).
    public dynamic var secondActionTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            secondActionButton.titleLabel?.font = secondActionTextFont
        }
    }

    /// Icon image
    public dynamic var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }

    /// Icon image content 
    public dynamic var iconContentMode: UIViewContentMode = .Center {
        didSet {
            iconImageView.contentMode = iconContentMode
        }
    }

    // MARK: -
    // MARK: Private property.

    private var iconImageView: UIImageView!
    private var messageLabel: UILabel!
    private var seperateView: UIView!
    private var actionButton: UIButton!
    private var secondActionButton: UIButton!
    private var activityIndicatorView: UIActivityIndicatorView!

    /// Timer to dismiss the snackbar.
    private var dismissTimer: NSTimer? = nil

    // Constraints.
    private var heightConstraint: NSLayoutConstraint? = nil
    private var leftMarginConstraint: NSLayoutConstraint? = nil
    private var rightMarginConstraint: NSLayoutConstraint? = nil
    private var bottomMarginConstraint: NSLayoutConstraint? = nil
    private var iconImageViewWidthConstraint: NSLayoutConstraint? = nil
    private var actionButtonWidthConstraint: NSLayoutConstraint? = nil
    private var secondActionButtonWidthConstraint: NSLayoutConstraint? = nil

    // MARK: -
    // MARK: Default init

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(frame: CGRect) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        configure()
    }

    /**
     Default init
     
     - returns: TTGSnackbar instance
     */
    public init() {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        configure()
    }

    /**
     Show a single message like a Toast.
     
     - parameter message:  Message text.
     - parameter duration: Duration type.
     
     - returns: TTGSnackbar instance
     */
    public init(message: String, duration: TTGSnackbarDuration) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
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
     
     - returns: TTGSnackbar instance
     */
    public init(message: String, duration: TTGSnackbarDuration, actionText: String, actionBlock: TTGActionBlock) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
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
     
     - returns: TTGSnackbar instance
     */
    public init(message: String, duration: TTGSnackbarDuration, actionText: String, messageFont: UIFont, actionTextFont: UIFont, actionBlock: TTGActionBlock) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        self.duration = duration
        self.message = message
        self.actionText = actionText
        self.actionBlock = actionBlock
        self.messageTextFont = messageFont
        self.actionTextFont = actionTextFont
        configure()
    }
}

// MARK: -
// MARK: Show methods.

public extension TTGSnackbar {

    /**
     Show the snackbar.
     */
    public func show() {
        // Only show once
        if self.superview != nil {
            return
        }

        // Create dismiss timer
        dismissTimer = NSTimer.scheduledTimerWithTimeInterval((NSTimeInterval)(duration.rawValue), target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)

        // Show or hide action button
        iconImageView.hidden = icon == nil
        actionButton.hidden = actionText.isEmpty || actionBlock == nil
        secondActionButton.hidden = secondActionText.isEmpty || secondActionBlock == nil
        seperateView.hidden = actionButton.hidden
        iconImageViewWidthConstraint?.constant = iconImageView.hidden ? 0 : TTGSnackbar.snackbarIconImageViewWidth
        actionButtonWidthConstraint?.constant = actionButton.hidden ? 0 : (secondActionButton.hidden ? TTGSnackbar.snackbarActionButtonMaxWidth : TTGSnackbar.snackbarActionButtonMinWidth)
        secondActionButtonWidthConstraint?.constant = secondActionButton.hidden ? 0 : (actionButton.hidden ? TTGSnackbar.snackbarActionButtonMaxWidth : TTGSnackbar.snackbarActionButtonMinWidth)

        self.layoutIfNeeded()

        // Get windows to show
        if let superView = UIApplication.sharedApplication().keyWindow {
            superView.addSubview(self)

            // Snackbar height constraint
            heightConstraint = NSLayoutConstraint.init(item: self, attribute: .Height,
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
            self.addConstraint(heightConstraint!)
            superView.addConstraint(leftMarginConstraint!)
            superView.addConstraint(rightMarginConstraint!)
            superView.addConstraint(bottomMarginConstraint!)

            // Show
            showWithAnimation()
        } else {
            fatalError("TTGSnackbar needs a keyWindows to display.")
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
}

// MARK: -
// MARK: Dismiss methods.

public extension TTGSnackbar {
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
     Invalid the dismiss timer.
     */
    private func invalidDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
}

// MARK: -
// MARK: Init configuration.

private extension TTGSnackbar {
    func configure() {
        // Clear subViews
        for subView in self.subviews {
            subView.removeFromSuperview()
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.backgroundColor = UIColor.clearColor()
        iconImageView.contentMode = iconContentMode
        self.addSubview(iconImageView)

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
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.setTitle(actionText, forState: .Normal)
        actionButton.setTitleColor(actionTextColor, forState: .Normal)
        actionButton.addTarget(self, action: #selector(doAction(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(actionButton)

        secondActionButton = UIButton()
        secondActionButton.translatesAutoresizingMaskIntoConstraints = false
        secondActionButton.backgroundColor = UIColor.clearColor()
        secondActionButton.titleLabel?.font = secondActionTextFont
        secondActionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        secondActionButton.setTitle(secondActionText, forState: .Normal)
        secondActionButton.setTitleColor(secondActionTextColor, forState: .Normal)
        secondActionButton.addTarget(self, action: #selector(doAction(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(secondActionButton)

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
        "H:|-2-[iconImageView]-2-[messageLabel]-2-[seperateView(0.5)]-2-[actionButton]-0-[secondActionButton]-4-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["iconImageView": iconImageView, "messageLabel": messageLabel, "seperateView": seperateView, "actionButton": actionButton, "secondActionButton": secondActionButton])

        let vConstraintsForIconImageView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-2-[iconImageView]-2-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["iconImageView": iconImageView])

        let vConstraintsForMessageLabel: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-0-[messageLabel]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["messageLabel": messageLabel])

        let vConstraintsForSeperateView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-4-[seperateView]-4-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["seperateView": seperateView])

        let vConstraintsForActionButton: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-0-[actionButton]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["actionButton": actionButton])

        let vConstraintsForSecondActionButton: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-0-[secondActionButton]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["secondActionButton": secondActionButton])

        iconImageViewWidthConstraint = NSLayoutConstraint.init(
        item: iconImageView, attribute: .Width, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarIconImageViewWidth)

        actionButtonWidthConstraint = NSLayoutConstraint.init(
        item: actionButton, attribute: .Width, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarActionButtonMinWidth)

        secondActionButtonWidthConstraint = NSLayoutConstraint.init(
        item: secondActionButton, attribute: .Width, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarActionButtonMinWidth)

        let vConstraintsForActivityIndicatorView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-2-[activityIndicatorView]-2-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["activityIndicatorView": activityIndicatorView])

        let hConstraintsForActivityIndicatorView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "H:[activityIndicatorView(activityIndicatorWidth)]-2-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: ["activityIndicatorWidth": height - 4],
                views: ["activityIndicatorView": activityIndicatorView])

        iconImageView.addConstraint(iconImageViewWidthConstraint!)
        actionButton.addConstraint(actionButtonWidthConstraint!)
        secondActionButton.addConstraint(secondActionButtonWidthConstraint!)

        self.addConstraints(hConstraints)
        self.addConstraints(vConstraintsForIconImageView)
        self.addConstraints(vConstraintsForMessageLabel)
        self.addConstraints(vConstraintsForSeperateView)
        self.addConstraints(vConstraintsForActionButton)
        self.addConstraints(vConstraintsForSecondActionButton)
        self.addConstraints(vConstraintsForActivityIndicatorView)
        self.addConstraints(hConstraintsForActivityIndicatorView)
    }
}

// MARK: -
// MARK: Actions

private extension TTGSnackbar {
    /**
     Action button callback
     
     - parameter button: action button
     */
    @objc func doAction(button: UIButton) {
        // Call action block first
        button == actionButton ? actionBlock?(snackbar: self) : secondActionBlock?(snackbar: self)

        // Show activity indicator
        if duration == .Forever && actionButton.hidden == false {
            actionButton.hidden = true
            secondActionButton.hidden = true
            seperateView.hidden = true
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
        } else {
            dismissAnimated(true)
        }
    }
}