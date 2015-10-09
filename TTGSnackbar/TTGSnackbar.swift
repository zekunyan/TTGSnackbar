//
//  TTGSnackbar.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

public enum TTGSnackbarDuration: NSTimeInterval {
    case TTGSnackbarDurationShort = 1.0
    case TTGSnackbarDurationMiddle = 3.0
    case TTGSnackbarDurationLong = 5.0
    case TTGSnackbarDurationForever = 9999999999.0 // Must dismiss manually.
}

public enum TTGSnackbarAnimationType {
    case TTGSnackbarAnimationFadeInFadeOut
    case TTGSnackbarAnimationSlideFromBottomToTop
    case TTGSnackbarAnimationSlideFromBottomBackToBottom
    case TTGSnackbarAnimationSlideFromLeftToRight
    case TTGSnackbarAnimationSlideFromRightToLeft
}

public class TTGSnackbar: UIView {
    // Current instance
    private static var currentInstance: TTGSnackbar? = nil
    // Constant
    private static let snackbarAnimationDuration: NSTimeInterval = 0.3
    private static let snackbarHeight: CGFloat = 44
    private static let snackbarBottomMargin: CGFloat = 4
    private static let snackbarHorizonMargin: CGFloat = 4
    private static let snackbarActionButtonWidth: CGFloat = 64

    // Callback block type
    public typealias TTGActionBlock = (snackbar:TTGSnackbar) -> Void
    public typealias TTGDismissBlock = (snackbar:TTGSnackbar) -> Void

    // Public
    public var actionBlock: TTGActionBlock? = nil
    public var dismissBlock: TTGDismissBlock? = nil
    public var duration: TTGSnackbarDuration = TTGSnackbarDuration.TTGSnackbarDurationShort
    public var animationType: TTGSnackbarAnimationType = TTGSnackbarAnimationType.TTGSnackbarAnimationSlideFromBottomBackToBottom
    public var message: String = "" {
        didSet {
            self.messageLabel.text = message
        }
    }
    public var messageTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.messageLabel.textColor = messageTextColor
        }
    }
    public var actionText: String = "" {
        didSet {
            self.actionButton.setTitle(actionText, forState: UIControlState.Normal)
        }
    }
    public var actionTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            actionButton.setTitleColor(actionTextColor, forState: UIControlState.Normal)
        }
    }

    // Private
    private var messageLabel: UILabel!
    private var seperateView: UIView!
    private var actionButton: UIButton!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var dismissTimer: NSTimer? = nil

    private var centerXConstraint: NSLayoutConstraint? = nil
    private var bottomMarginConstraint: NSLayoutConstraint? = nil
    private var actionButtonWidthConstraint: NSLayoutConstraint? = nil
    // Action button width

    // --Public init--
    public init(message: String, duration: TTGSnackbarDuration) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        self.duration = duration
        self.message = message
        configure()
    }

    public init(message: String, duration: TTGSnackbarDuration, actionText: String, actionBlock: TTGActionBlock) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        self.duration = duration
        self.message = message
        self.actionText = actionText
        self.actionBlock = actionBlock
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // --Public methods--
    public func show() {
        // Only show once
        if self.superview != nil {
            return
        }

        // Dismiss last bar
        TTGSnackbar.currentInstance?.dismissAnimated(false)

        // Save current show instance
        TTGSnackbar.currentInstance = self

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
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarHeight)

            // Snackbar width constraint
            let widthConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: superView.bounds.width - 2 * TTGSnackbar.snackbarHorizonMargin)

            // Center X constraint
            centerXConstraint = NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)

            // Bottom margin constraint
            bottomMarginConstraint = NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)

            // Add constraints
            self.addConstraint(heightConstraint)
            self.addConstraint(widthConstraint)
            superView.addConstraint(bottomMarginConstraint!)
            superView.addConstraint(centerXConstraint!)

            // Show 
            showWithAnimation()
        }
    }

    public func dismiss() {
        // On main thread
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.dismissAnimated(true)
        }
    }

    // --Private methods--
    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true

        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.textAlignment = NSTextAlignment.Left
        messageLabel.text = message
        self.addSubview(messageLabel)

        actionButton = UIButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = UIColor.clearColor()
        actionButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        actionButton.setTitle(actionText, forState: UIControlState.Normal)
        actionButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        actionButton.addTarget(self, action: Selector("doAction"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(actionButton)

        seperateView = UIView()
        seperateView.translatesAutoresizingMaskIntoConstraints = false
        seperateView.backgroundColor = UIColor.grayColor()
        self.addSubview(seperateView)

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
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
        item: actionButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
                toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarActionButtonWidth)

        let vConstraintsForActivityIndicatorView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-(2)-[activityIndicatorView]-(2)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["activityIndicatorView": activityIndicatorView])

        let hConstraintsForActivityIndicatorView: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(
        "H:[activityIndicatorView(activityIndicatorWidth)]-(2)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: ["activityIndicatorWidth": TTGSnackbar.snackbarHeight - 4],
                views: ["activityIndicatorView": activityIndicatorView])

        self.addConstraints(hConstraints)
        self.addConstraints(vConstraintsForMessageLabel)
        self.addConstraints(vConstraintsForSeperateView)
        self.addConstraints(vConstraintsForActionButton)
        self.addConstraints(vConstraintsForActivityIndicatorView)
        self.addConstraints(hConstraintsForActivityIndicatorView)
        actionButton.addConstraint(actionButtonWidthConstraint!)
    }

    private func invalidDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }

    private func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }

    private func dismissAnimated(animated: Bool) {
        invalidDismissTimer()
        activityIndicatorView.stopAnimating()
        TTGSnackbar.currentInstance = nil

        if !animated {
            dismissBlock?(snackbar: self)
            self.removeFromSuperview()
            return
        }

        var animationBlock: (() -> Void)? = nil

        switch animationType {
        case .TTGSnackbarAnimationFadeInFadeOut:
            animationBlock = {
                self.alpha = 0.0
            }
        case .TTGSnackbarAnimationSlideFromBottomBackToBottom:
            bottomMarginConstraint?.constant = TTGSnackbar.snackbarHeight
        case .TTGSnackbarAnimationSlideFromBottomToTop:
            animationBlock = {
                self.alpha = 0.0
            }
            bottomMarginConstraint?.constant = -TTGSnackbar.snackbarHeight - TTGSnackbar.snackbarBottomMargin
        case .TTGSnackbarAnimationSlideFromLeftToRight:
            centerXConstraint?.constant = superview!.bounds.width
        case .TTGSnackbarAnimationSlideFromRightToLeft:
            centerXConstraint?.constant = -superview!.bounds.width
        }

        self.setNeedsLayout()
        UIView.animateWithDuration(TTGSnackbar.snackbarAnimationDuration,
                delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.CurveEaseIn,
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

    private func showWithAnimation() {
        var animationBlock: (() -> Void)? = nil

        switch animationType {
        case .TTGSnackbarAnimationFadeInFadeOut:
            bottomMarginConstraint?.constant = -TTGSnackbar.snackbarBottomMargin
            self.layoutIfNeeded()
            self.alpha = 0.0
            animationBlock = {
                self.alpha = 1.0
            }
        case .TTGSnackbarAnimationSlideFromBottomBackToBottom, .TTGSnackbarAnimationSlideFromBottomToTop:
            // Init
            bottomMarginConstraint?.constant = TTGSnackbar.snackbarHeight
            self.layoutIfNeeded()
            // Animation
            bottomMarginConstraint?.constant = -TTGSnackbar.snackbarBottomMargin
        case .TTGSnackbarAnimationSlideFromLeftToRight:
            // Init
            centerXConstraint?.constant = -superview!.bounds.width
            bottomMarginConstraint?.constant = -TTGSnackbar.snackbarBottomMargin
            self.layoutIfNeeded()
            // Animation
            centerXConstraint?.constant = 0
        case .TTGSnackbarAnimationSlideFromRightToLeft:
            // Init
            centerXConstraint?.constant = superview!.bounds.width
            bottomMarginConstraint?.constant = -TTGSnackbar.snackbarBottomMargin
            self.layoutIfNeeded()
            // Animation
            centerXConstraint?.constant = 0
        }

        self.setNeedsLayout()

        UIView.animateWithDuration(TTGSnackbar.snackbarAnimationDuration,
                delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                    () -> Void in
                    animationBlock?()
                    self.layoutIfNeeded()
                }, completion: nil)
    }

    // Button action
    func doAction() {
        // Call action block first
        actionBlock?(snackbar: self)

        // Show activity indicator
        if duration == TTGSnackbarDuration.TTGSnackbarDurationForever && actionButton.hidden == false {
            actionButton.hidden = true
            seperateView.hidden = true
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
        } else {
            dismissAnimated(true)
        }
    }
}
