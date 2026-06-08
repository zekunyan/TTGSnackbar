//
//  TTGSnackbar.swift
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

open class TTGSnackbar: UIView {
    // MARK: - Class property.

    /// Snackbar default frame
    @objc public static var snackbarDefaultFrame: CGRect = CGRect(x: 0, y: 0, width: 320, height: 44)

    /// Snackbar min height
    @objc public static var snackbarMinHeight: CGFloat = 44

    // MARK: - Typealias.

    /// Action callback closure definition.
    public typealias TTGActionBlock = (_ snackbar:TTGSnackbar) -> Void

    /// Dismiss callback closure definition.
    public typealias TTGDismissBlock = (_ snackbar:TTGSnackbar) -> Void

    /// Lifecycle callback closure definition.
    public typealias TTGLifecycleBlock = (_ snackbar: TTGSnackbar) -> Void

    /// Swipe gesture callback closure
    public typealias TTGSwipeBlock = (_ snackbar: TTGSnackbar, _ direction: UISwipeGestureRecognizer.Direction) -> Void

    // MARK: - Public property.

    /// Tap callback
    @objc open dynamic var onTapBlock: TTGActionBlock?

    /// Swipe callback
    @objc open dynamic var onSwipeBlock: TTGSwipeBlock?

    /// A property to make the snackbar auto dismiss on Swipe Gesture
    @objc open dynamic var shouldDismissOnSwipe: Bool = false

    /// A property to enable left and right margin when using customContentView
    @objc open dynamic var shouldActivateLeftAndRightMarginOnCustomContentView: Bool = false

    /// A property to allow for disabling the use of "Safe Area Layout Guides" on newer OS devices.
    /// The purpose of this is to allow the a snackbar to extend under the "Swipe Up for Home" area
    /// on iPhone X and newer devices.
    @objc open dynamic var shouldHonorSafeAreaLayoutGuides: Bool = true

    /// Action callback.
    @objc open dynamic var actionBlock: TTGActionBlock? = nil

    /// Second action block
    @objc open dynamic var secondActionBlock: TTGActionBlock? = nil

    /// Dismiss callback.
    @objc open dynamic var dismissBlock: TTGDismissBlock? = nil

    /// Called before the snackbar starts presenting.
    @objc open dynamic var willShowBlock: TTGLifecycleBlock? = nil

    /// Called after the snackbar presentation animation finishes.
    @objc open dynamic var didShowBlock: TTGLifecycleBlock? = nil

    /// Called before the snackbar starts dismissing.
    @objc open dynamic var willDismissBlock: TTGLifecycleBlock? = nil

    /// Called after the snackbar has been removed from its superview.
    @objc open dynamic var didDismissBlock: TTGLifecycleBlock? = nil

    /// Semantic style that applies recommended colors, icons, haptics and loading behavior.
    @objc open dynamic var style: TTGSnackbarStyle = .default {
        didSet {
            apply(style: style)
        }
    }

    /// Haptic feedback played when the snackbar is shown.
    @objc open dynamic var hapticFeedback: TTGSnackbarHapticFeedback = .none

    /// Haptic feedback played when the primary or secondary action is tapped.
    @objc open dynamic var actionHapticFeedback: TTGSnackbarHapticFeedback = .selection

    /// Announce the snackbar message with VoiceOver when shown.
    @objc open dynamic var shouldAnnounceForAccessibility: Bool = true

    /// Custom VoiceOver announcement. Uses the snackbar message when nil.
    @objc open dynamic var accessibilityAnnouncement: String? = nil

    /// Respect Reduce Motion by falling back to a fade animation.
    @objc open dynamic var shouldRespectReduceMotion: Bool = true

    /// Scale built-in label fonts with Dynamic Type.
    @objc open dynamic var adjustsFontForContentSizeCategory: Bool = true {
        didSet {
            messageLabel?.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
            actionButton?.titleLabel?.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
            secondActionButton?.titleLabel?.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        }
    }

    /// Pause the auto-dismiss timer while the app is inactive.
    @objc open dynamic var pausesDismissTimerWhenAppInactive: Bool = true

    /// Pause the auto-dismiss timer while the user is touching the snackbar.
    @objc open dynamic var pausesDismissTimerOnTouch: Bool = true

    /// Snackbar display duration. Default is Short = 1 second.
    @objc open dynamic var duration: TTGSnackbarDuration = TTGSnackbarDuration.short

    /// Snackbar custom display duration (Unit: second). Default is -1 which means invalid.
    @objc open dynamic var customDuration: TimeInterval = -1

    /// Snackbar animation type. Default is SlideFromBottomBackToBottom.
    @objc open dynamic var animationType: TTGSnackbarAnimationType = TTGSnackbarAnimationType.slideFromBottomBackToBottom

    /// Show and hide animation duration. Default is 0.3
    @objc open dynamic var animationDuration: TimeInterval = 0.3

    /// Corner radius: [0, height / 2]. Default is 4
    @objc open dynamic var cornerRadius: CGFloat = 4 {
        didSet {
            cornerRadius = max(cornerRadius, 0)
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }

    /// Snackbar max width, default full width
    @objc open dynamic var snackbarMaxWidth: CGFloat = -1 // Less than 0 is unused

    /// Border color of snackbar. Default is clear.
    @objc open dynamic var borderColor: UIColor? = .clear {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    /// Border width of snackbar. Default is 1.
    @objc open dynamic var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    /// Top margin. Default is 4, only work when snackbar is at top
    @objc open dynamic var topMargin: CGFloat = 4 {
        didSet {
            topMarginConstraint?.constant = topMargin
            superview?.layoutIfNeeded()
        }
    }

    /// Bottom margin. Default is 4, only work when snackbar is at bottom
    @objc open dynamic var bottomMargin: CGFloat = 4 {
        didSet {
            bottomMarginConstraint?.constant = -bottomMargin
            superview?.layoutIfNeeded()
        }
    }

    /// Left margin. Default is 4
    @objc open dynamic var leftMargin: CGFloat = 4 {
        didSet {
            leftMarginConstraint?.constant = leftMargin
            superview?.layoutIfNeeded()
        }
    }

    /// Right margin. Default is 4
    @objc open dynamic var rightMargin: CGFloat = 4 {
        didSet {
            rightMarginConstraint?.constant = -rightMargin
            superview?.layoutIfNeeded()
        }
    }

    /// Content inset. Default is (0, 4, 0, 4)
    @objc open dynamic var contentInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4) {
        didSet {
            contentViewTopConstraint?.constant = contentInset.top
            contentViewBottomConstraint?.constant = -contentInset.bottom
            contentViewLeftConstraint?.constant = contentInset.left
            contentViewRightConstraint?.constant = -contentInset.right
            layoutIfNeeded()
            superview?.layoutIfNeeded()
        }
    }

    /// Label content inset. Default is (0, 0, 0, 0)
    @objc open dynamic var messageContentInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            messageLabel.contentInset = messageContentInset
        }
    }

    /// Main text label
    @objc fileprivate(set) open dynamic var messageLabel: TTGSnackbarLabel!

    /// Main text shown on the snackbar.
    @objc open dynamic var message: String = "" {
        didSet {
            messageLabel.text = message
        }
    }

    /// Message text color. Default is white.
    @objc open dynamic var messageTextColor: UIColor = UIColor.ttgDefaultText {
        didSet {
            messageLabel.textColor = messageTextColor
        }
    }

    /// Message text font. Default is Bold system font (14).
    @objc open dynamic var messageTextFont: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            messageLabel.font = messageTextFont
        }
    }

    /// Message text alignment. Default is left
    @objc open dynamic var messageTextAlign: NSTextAlignment = .left {
        didSet {
            messageLabel.textAlignment = messageTextAlign
        }
    }

    /// Action button
    @objc fileprivate(set) open dynamic var actionButton: UIButton!

    /// Action button title.
    @objc open dynamic var actionText: String = "" {
        didSet {
            actionButton.setTitle(actionText, for: UIControl.State())
        }
    }

    /// Action button image.
    @objc open dynamic var actionIcon: UIImage? = nil {
        didSet {
            actionButton.setImage(actionIcon, for: UIControl.State())
        }
    }

    /// Second action button
    @objc fileprivate(set) open dynamic var secondActionButton: UIButton!

    /// Second action button title.
    @objc open dynamic var secondActionText: String = "" {
        didSet {
            secondActionButton.setTitle(secondActionText, for: UIControl.State())
        }
    }

    /// Second action button image.
    @objc open dynamic var secondActionIcon: UIImage? = nil {
        didSet {
            secondActionButton.setImage(secondActionIcon, for: UIControl.State())
        }
    }

    /// Action button title color. Default is white.
    @objc open dynamic var actionTextColor: UIColor = UIColor.ttgDefaultText {
        didSet {
            actionButton.setTitleColor(actionTextColor, for: UIControl.State())
        }
    }

    /// Second action button title color. Default is white.
    @objc open dynamic var secondActionTextColor: UIColor = UIColor.ttgDefaultText {
        didSet {
            secondActionButton.setTitleColor(secondActionTextColor, for: UIControl.State())
        }
    }

    /// Action text font. Default is Bold system font (14).
    @objc open dynamic var actionTextFont: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            actionButton.titleLabel?.font = actionTextFont
        }
    }

    /// Second action text font. Default is Bold system font (14).
    @objc open dynamic var secondActionTextFont: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            secondActionButton.titleLabel?.font = secondActionTextFont
        }
    }

    /// All action button max width, min = 44
    @objc open dynamic var actionMaxWidth: CGFloat = 64 {
        didSet {
            actionMaxWidth = max(actionMaxWidth, 44)
            actionButtonMaxWidthConstraint?.constant = actionButton.isHidden ? 0 : actionMaxWidth
            secondActionButtonMaxWidthConstraint?.constant = secondActionButton.isHidden ? 0 : actionMaxWidth
            layoutIfNeeded()
        }
    }

    /// All action button text number of lines. Default is 1
    @objc open dynamic var actionTextNumberOfLines: Int = 1 {
        didSet {
            actionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
            secondActionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
            layoutIfNeeded()
        }
    }

    /// Icon imageView
    @objc fileprivate(set) open dynamic var iconImageView: UIImageView!

    /// Icon image
    @objc open dynamic var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }

    /// Icon image content
    @objc open dynamic var iconContentMode: UIView.ContentMode = .center {
        didSet {
            iconImageView.contentMode = iconContentMode
        }
    }

    /// Icon background color. Default is clear.
    @objc open dynamic var iconBackgroundColor: UIColor? = .clear {
        didSet {
            iconImageView.backgroundColor = iconBackgroundColor
        }
    }

    /// Icon tint color
    @objc open dynamic var iconTintColor: UIColor! = .clear {
        didSet {
            iconImageView.tintColor = iconTintColor
        }
    }

    /// Icon width
    @objc open dynamic var iconImageViewWidth: CGFloat = 32 {
        didSet {
            iconImageViewWidth = max(iconImageViewWidth, 32)
            iconImageViewWidthConstraint?.constant = iconImageView.isHidden ? 0 : iconImageViewWidth
            layoutIfNeeded()
        }
    }

    /// Custom container view
    @objc open dynamic var containerView: UIView?

    /// Custom content view
    @objc open dynamic var customContentView: UIView?

    /// SeparateView background color
    @objc open dynamic var separateViewBackgroundColor: UIColor = UIColor.systemGray {
        didSet {
            separateView.backgroundColor = separateViewBackgroundColor
        }
    }

    /// ActivityIndicatorView
    @objc fileprivate(set) open dynamic var activityIndicatorView: UIActivityIndicatorView!

    /// ActivityIndicatorViewStyle
    @objc open dynamic var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
        get {
            return activityIndicatorView.style
        }
        set {
            activityIndicatorView.style = newValue
        }
    }

    /// ActivityIndicatorView color
    @objc open dynamic var activityIndicatorViewColor: UIColor {
        get {
            return activityIndicatorView.color ?? .white
        }
        set {
            activityIndicatorView.color = newValue
        }
    }

    /// Animation SpringWithDamping. Default is 0.7
    @objc open dynamic var animationSpringWithDamping: CGFloat = 0.7

    /// Animation initialSpringVelocity. Default is 5
    @objc open dynamic var animationInitialSpringVelocity: CGFloat = 5

    // MARK: - Private property.

    fileprivate var contentView: UIView!
    fileprivate var separateView: UIView!

    /// Timer to dismiss the snackbar.
    fileprivate var dismissTimer: Timer? = nil
    fileprivate var dismissTimerStartedAt: Date? = nil
    fileprivate var dismissTimeInterval: TimeInterval = 0
    fileprivate var remainingDismissTime: TimeInterval? = nil
    fileprivate var isDismissTimerPaused: Bool = false
    fileprivate var isDismissing: Bool = false

    /// Keyboard mark
    fileprivate var keyboardIsShown: Bool = false
    fileprivate var keyboardHeight: CGFloat = 0

    // Constraints.
    fileprivate var leftMarginConstraint: NSLayoutConstraint? = nil
    fileprivate var rightMarginConstraint: NSLayoutConstraint? = nil
    fileprivate var bottomMarginConstraint: NSLayoutConstraint? = nil
    fileprivate var topMarginConstraint: NSLayoutConstraint? = nil // Only work when top animation type
    fileprivate var centerXConstraint: NSLayoutConstraint? = nil

    // Content constraints.
    fileprivate var iconImageViewWidthConstraint: NSLayoutConstraint? = nil
    fileprivate var actionButtonMaxWidthConstraint: NSLayoutConstraint? = nil
    fileprivate var secondActionButtonMaxWidthConstraint: NSLayoutConstraint? = nil

    fileprivate var contentViewLeftConstraint: NSLayoutConstraint? = nil
    fileprivate var contentViewRightConstraint: NSLayoutConstraint? = nil
    fileprivate var contentViewTopConstraint: NSLayoutConstraint? = nil
    fileprivate var contentViewBottomConstraint: NSLayoutConstraint? = nil

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Default init

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
    @objc public init(message: String, duration: TTGSnackbarDuration) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        self.duration = duration
        self.message = message
        configure()
    }

    /**
     Initialize a snackbar from a value-based Swift configuration.

     - parameter configuration: Configuration containing message, duration, style and actions.
     */
    public convenience init(configuration: TTGSnackbarConfiguration) {
        self.init(message: configuration.message, duration: configuration.duration)
        style = configuration.style
        if let actionText = configuration.actionText {
            self.actionText = actionText
        }
        actionBlock = configuration.actionBlock
        if let secondActionText = configuration.secondActionText {
            self.secondActionText = secondActionText
        }
        secondActionBlock = configuration.secondActionBlock
        icon = configuration.icon
        if let customDuration = configuration.customDuration {
            self.customDuration = customDuration
        }
        apply(style: configuration.style)
    }

    /**
     Show a customContentView like a Toast

     - parameter customContentView: Custom View to be shown.
     - parameter duration: Duration type.

     - returns: TTGSnackbar instance
     */
    public init(customContentView: UIView, duration: TTGSnackbarDuration) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        self.duration = duration
        self.customContentView = customContentView
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
    public init(message: String, duration: TTGSnackbarDuration, actionText: String, actionBlock: @escaping TTGActionBlock) {
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
    public init(message: String, duration: TTGSnackbarDuration, actionText: String, messageFont: UIFont, actionTextFont: UIFont, actionBlock: @escaping TTGActionBlock) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        self.duration = duration
        self.message = message
        self.actionText = actionText
        self.actionBlock = actionBlock
        self.messageTextFont = messageFont
        self.actionTextFont = actionTextFont
        configure()
    }

    // Override
    open override func layoutSubviews() {
        super.layoutSubviews()
        if messageLabel.preferredMaxLayoutWidth != messageLabel.frame.size.width {
            messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
            setNeedsLayout()
        }
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if pausesDismissTimerOnTouch {
            pauseDismissTimer()
        }
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if pausesDismissTimerOnTouch {
            resumeDismissTimer()
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if pausesDismissTimerOnTouch {
            resumeDismissTimer()
        }
    }
}

// MARK: - Window lookup.

private extension TTGSnackbar {
    static var activeWindow: UIWindow? {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let foregroundScenes = windowScenes
            .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }

        return foregroundScenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            ?? foregroundScenes.flatMap(\.windows).first
            ?? windowScenes.flatMap(\.windows).first(where: \.isKeyWindow)
            ?? windowScenes.flatMap(\.windows).first
    }
}

// MARK: - Show methods.

public extension TTGSnackbar {

    /// Presents a configured snackbar and asynchronously returns the first user or dismiss result.
    @MainActor
    static func show(
        configuration: TTGSnackbarConfiguration,
        manager: TTGSnackbarManager? = nil,
        policy: TTGSnackbarPresentationPolicy = .enqueue
    ) async -> TTGSnackbarResult {
        await withCheckedContinuation { continuation in
            let snackbar = TTGSnackbar(configuration: configuration)
            var didResume = false

            func resume(_ result: TTGSnackbarResult) {
                guard !didResume else { return }
                didResume = true
                continuation.resume(returning: result)
            }

            let existingActionBlock = snackbar.actionBlock
            snackbar.actionBlock = { snackbar in
                existingActionBlock?(snackbar)
                resume(.action)
            }

            let existingSecondActionBlock = snackbar.secondActionBlock
            snackbar.secondActionBlock = { snackbar in
                existingSecondActionBlock?(snackbar)
                resume(.secondAction)
            }

            let existingTapBlock = snackbar.onTapBlock
            snackbar.onTapBlock = { snackbar in
                existingTapBlock?(snackbar)
                resume(.tapped)
            }

            let existingSwipeBlock = snackbar.onSwipeBlock
            snackbar.onSwipeBlock = { snackbar, direction in
                existingSwipeBlock?(snackbar, direction)
                resume(.swiped(direction))
            }

            let existingDidDismissBlock = snackbar.didDismissBlock
            snackbar.didDismissBlock = { snackbar in
                existingDidDismissBlock?(snackbar)
                resume(.dismissed)
            }

            if let manager = manager {
                manager.show(snackbar: snackbar, policy: policy)
            } else {
                snackbar.show()
            }
        }
    }

    /**
     Show the snackbar.
     */
    @objc func show() {
        // Only show once
        if superview != nil {
            return
        }

        isDismissing = false
        willShowBlock?(self)
        apply(style: style)

        // Determine the final display duration and create a dismiss timer when needed.
        let timeInterval = resolvedDisplayDuration()
        if duration != .forever {
            scheduleDismissTimer(timeInterval: timeInterval)
        }

        // Show or hide action button
        iconImageView.isHidden = icon == nil

        actionButton.isHidden = actionBlock == nil || (actionText.isEmpty && actionIcon == nil)
        secondActionButton.isHidden = secondActionBlock == nil || (secondActionText.isEmpty && secondActionIcon == nil)

        separateView.isHidden = actionButton.isHidden

        iconImageViewWidthConstraint?.constant = iconImageView.isHidden ? 0 : iconImageViewWidth
        actionButtonMaxWidthConstraint?.constant = actionButton.isHidden ? 0 : actionMaxWidth
        secondActionButtonMaxWidthConstraint?.constant = secondActionButton.isHidden ? 0 : actionMaxWidth

        // Content View
        let finalContentView = customContentView ?? contentView
        finalContentView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(finalContentView!)

        contentViewTopConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .top, relatedBy: .equal,
                                                           toItem: self, attribute: .top, multiplier: 1, constant: contentInset.top)
        contentViewBottomConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .bottom, relatedBy: .equal,
                                                              toItem: self, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
        contentViewLeftConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .leading, relatedBy: .equal,
                                                            toItem: self, attribute: .leading, multiplier: 1, constant: contentInset.left)
        contentViewRightConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .trailing, relatedBy: .equal,
                                                             toItem: self, attribute: .trailing, multiplier: 1, constant: -contentInset.right)

        addConstraints([contentViewTopConstraint!, contentViewBottomConstraint!, contentViewLeftConstraint!, contentViewRightConstraint!])

        // Get super view to show
        if let superView = containerView ?? TTGSnackbar.activeWindow {
            superView.addSubview(self)

            let relativeToItem: Any = shouldHonorSafeAreaLayoutGuides ? superView.safeAreaLayoutGuide : superView

            // Left margin constraint
            leftMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .leading, relatedBy: .equal,
                toItem: relativeToItem, attribute: .leading, multiplier: 1, constant: leftMargin)

            // Right margin constraint
            rightMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .trailing, relatedBy: .equal,
                toItem: relativeToItem, attribute: .trailing, multiplier: 1, constant: -rightMargin)


            // Bottom margin constraint
            bottomMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .bottom, relatedBy: .equal,
                toItem: relativeToItem, attribute: .bottom, multiplier: 1, constant: -bottomMargin)

            // Top margin constraint
            topMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .top, relatedBy: .equal,
                toItem: relativeToItem, attribute: .top, multiplier: 1, constant: topMargin)

            // Center X constraint
            centerXConstraint = NSLayoutConstraint.init(
                item: self, attribute: .centerX, relatedBy: .equal,
                toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)

            // Min height constraint
            let minHeightConstraint = NSLayoutConstraint.init(
                item: self, attribute: .height, relatedBy: .greaterThanOrEqual,
                toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarMinHeight)

            // Avoid the "UIView-Encapsulated-Layout-Height" constraint conflicts
            // http://stackoverflow.com/questions/25059443/what-is-nslayoutconstraint-uiview-encapsulated-layout-height-and-how-should-i
            leftMarginConstraint?.priority = UILayoutPriority(999)
            rightMarginConstraint?.priority = UILayoutPriority(999)
            topMarginConstraint?.priority = UILayoutPriority(999)
            bottomMarginConstraint?.priority = UILayoutPriority(999)
            centerXConstraint?.priority = UILayoutPriority(999)

            // Add constraints
            if snackbarMaxWidth > 0{
                centerXConstraint?.isActive = true

            } else {
                superView.addConstraint(leftMarginConstraint!)
                superView.addConstraint(rightMarginConstraint!)
                leftMarginConstraint?.isActive = self.shouldActivateLeftAndRightMarginOnCustomContentView ? true : customContentView == nil
                rightMarginConstraint?.isActive = self.shouldActivateLeftAndRightMarginOnCustomContentView ? true : customContentView == nil
                centerXConstraint?.isActive = customContentView != nil
            }

            superView.addConstraint(bottomMarginConstraint!)
            superView.addConstraint(topMarginConstraint!)
            superView.addConstraint(centerXConstraint!)
            superView.addConstraint(minHeightConstraint)

            // Active or deactive
            topMarginConstraint?.isActive = false // For top animation

            // Show
            playHapticFeedback(hapticFeedback)
            showWithAnimation()

            // Accessibility announcement.
            announceForAccessibilityIfNeeded()
        } else {
            debugPrint("TTGSnackbar needs an active window to display.")
        }
    }

    /**
     Show.
     */
    fileprivate func showWithAnimation() {
        var animationBlock: (() -> Void)? = nil
        let currentSuperViewWidth = (superview?.frame)!.width
        var superViewWidth = snackbarMaxWidth <= 0 ? currentSuperViewWidth : snackbarMaxWidth
        if superViewWidth > currentSuperViewWidth{
            superViewWidth = currentSuperViewWidth
        }
        let snackbarHeight = systemLayoutSizeFitting(.init(width: superViewWidth - leftMargin - rightMargin, height: TTGSnackbar.snackbarMinHeight)).height

        switch effectiveAnimationType {

        case .fadeInFadeOut:
            alpha = 0.0
            // Animation
            animationBlock = {
                self.alpha = 1.0
            }

        case .slideFromBottomBackToBottom, .slideFromBottomToTop:
            bottomMarginConstraint?.constant = snackbarHeight

        case .slideFromLeftToRight:
            leftMarginConstraint?.constant = leftMargin - superViewWidth
            rightMarginConstraint?.constant = -rightMargin - superViewWidth
            bottomMarginConstraint?.constant = -bottomMargin
            centerXConstraint?.constant = -superViewWidth

        case .slideFromRightToLeft:
            leftMarginConstraint?.constant = leftMargin + superViewWidth
            rightMarginConstraint?.constant = -rightMargin + superViewWidth
            bottomMarginConstraint?.constant = -bottomMargin
            centerXConstraint?.constant = superViewWidth

        case .slideFromTopBackToTop, .slideFromTopToBottom:
            bottomMarginConstraint?.isActive = false
            topMarginConstraint?.isActive = true
            topMarginConstraint?.constant = -snackbarHeight
        }

        // Update init state
        superview?.layoutIfNeeded()

        // Final state
        bottomMarginConstraint?.constant = -bottomMargin
        topMarginConstraint?.constant = topMargin
        leftMarginConstraint?.constant = leftMargin
        rightMarginConstraint?.constant = -rightMargin
        centerXConstraint?.constant = 0

        UIView.animate(withDuration: effectiveAnimationDuration, delay: 0,
                       usingSpringWithDamping: animationSpringWithDamping,
                       initialSpringVelocity: animationInitialSpringVelocity, options: .allowUserInteraction,
                       animations: {
                        () -> Void in
                        animationBlock?()
                        self.superview?.layoutIfNeeded()
        }) { _ in
            self.didShowBlock?(self)
        }
    }
}

// MARK: - Dismiss methods.

public extension TTGSnackbar {

    /// Pause the auto-dismiss timer and preserve remaining display time.
    @objc func pauseDismissTimer() {
        guard duration != .forever, !isDismissTimerPaused, let startedAt = dismissTimerStartedAt else { return }
        let elapsed = Date().timeIntervalSince(startedAt)
        remainingDismissTime = max(0.1, dismissTimeInterval - elapsed)
        dismissTimer?.invalidate()
        dismissTimer = nil
        dismissTimerStartedAt = nil
        isDismissTimerPaused = true
    }

    /// Resume a paused auto-dismiss timer.
    @objc func resumeDismissTimer() {
        guard duration != .forever, isDismissTimerPaused else { return }
        scheduleDismissTimer(timeInterval: remainingDismissTime ?? resolvedDisplayDuration())
    }

    /**
     Dismiss the snackbar manually.
     */
    @objc func dismiss() {
        // On main thread
        DispatchQueue.main.async {
            () -> Void in
            self.dismissAnimated(true)
        }
    }

    /**
     Dismiss.

     - parameter animated: If dismiss with animation.
     */
    fileprivate func dismissAnimated(_ animated: Bool) {
        if superview == nil || isDismissing {
            return
        }

        // If the dismiss timer is nil, snackbar is not ready to dismiss.
        if dismissTimer == nil && duration != .forever && !isDismissTimerPaused {
            return
        }

        isDismissing = true
        willDismissBlock?(self)
        invalidDismissTimer()
        activityIndicatorView.stopAnimating()

        let superViewWidth = (superview?.frame)!.width
        let snackbarHeight = frame.size.height
        let safeAreaInsets = superview?.safeAreaInsets ?? .zero

        if !animated {
            dismissBlock?(self)
            removeFromSuperview()
            didDismissBlock?(self)
            return
        }

        var animationBlock: (() -> Void)? = nil

        switch effectiveAnimationType {

        case .fadeInFadeOut:
            animationBlock = {
                self.alpha = 0.0
            }

        case .slideFromBottomBackToBottom:
            bottomMarginConstraint?.constant = snackbarHeight + safeAreaInsets.bottom

        case .slideFromBottomToTop:
            animationBlock = {
                self.alpha = 0.0
            }
            bottomMarginConstraint?.constant = -snackbarHeight - bottomMargin

        case .slideFromLeftToRight:
            leftMarginConstraint?.constant = leftMargin + superViewWidth + safeAreaInsets.left
            rightMarginConstraint?.constant = -rightMargin + superViewWidth - safeAreaInsets.right
            centerXConstraint?.constant = superViewWidth

        case .slideFromRightToLeft:
            leftMarginConstraint?.constant = leftMargin - superViewWidth + safeAreaInsets.left
            rightMarginConstraint?.constant = -rightMargin - superViewWidth - safeAreaInsets.right
            centerXConstraint?.constant = -superViewWidth

        case .slideFromTopToBottom:
            topMarginConstraint?.isActive = false
            bottomMarginConstraint?.isActive = true
            bottomMarginConstraint?.constant = snackbarHeight + safeAreaInsets.bottom

        case .slideFromTopBackToTop:
            topMarginConstraint?.constant = -snackbarHeight - safeAreaInsets.top
        }

        setNeedsLayout()

        UIView.animate(withDuration: effectiveAnimationDuration, delay: 0,
                       usingSpringWithDamping: animationSpringWithDamping,
                       initialSpringVelocity: animationInitialSpringVelocity, options: .curveEaseIn,
                       animations: {
                        () -> Void in
                        animationBlock?()
                        self.superview?.layoutIfNeeded()
        }) {
            (finished) -> Void in
            self.dismissBlock?(self)
            self.removeFromSuperview()
            self.didDismissBlock?(self)
        }
    }

    /**
     Invalid the dismiss timer.
     */
    fileprivate func invalidDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        dismissTimerStartedAt = nil
        remainingDismissTime = nil
        isDismissTimerPaused = false
    }
}

// MARK: - Modern behavior helpers.

private extension TTGSnackbar {
    var effectiveAnimationType: TTGSnackbarAnimationType {
        if shouldRespectReduceMotion && UIAccessibility.isReduceMotionEnabled {
            return .fadeInFadeOut
        }
        return animationType
    }

    var effectiveAnimationDuration: TimeInterval {
        if shouldRespectReduceMotion && UIAccessibility.isReduceMotionEnabled {
            return min(animationDuration, 0.2)
        }
        return animationDuration
    }

    func resolvedDisplayDuration() -> TimeInterval {
        let rawDuration = duration == .custom ? customDuration : TimeInterval(duration.rawValue)
        return max(rawDuration, TimeInterval(TTGSnackbarDuration.short.rawValue))
    }

    func scheduleDismissTimer(timeInterval: TimeInterval) {
        dismissTimer?.invalidate()
        dismissTimeInterval = timeInterval
        remainingDismissTime = nil
        isDismissTimerPaused = false
        dismissTimerStartedAt = Date()
        dismissTimer = Timer(timeInterval: timeInterval, target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
        RunLoop.main.add(dismissTimer!, forMode: .common)
    }

    func apply(style: TTGSnackbarStyle) {
        guard contentView != nil else { return }

        switch style {
        case .default:
            backgroundColor = UIColor.ttgDefaultBackground
            messageTextColor = UIColor.ttgDefaultText
            actionTextColor = UIColor.ttgDefaultText
            secondActionTextColor = UIColor.ttgDefaultText
            activityIndicatorView.stopAnimating()

        case .info:
            backgroundColor = .systemBlue
            messageTextColor = .white
            actionTextColor = .white
            secondActionTextColor = .white
            hapticFeedback = .selection

        case .success:
            backgroundColor = .systemGreen
            messageTextColor = .white
            actionTextColor = .white
            secondActionTextColor = .white
            icon = icon ?? UIImage(systemName: "checkmark.circle.fill")
            iconTintColor = .white
            hapticFeedback = .success

        case .warning:
            backgroundColor = .systemOrange
            messageTextColor = .white
            actionTextColor = .white
            secondActionTextColor = .white
            icon = icon ?? UIImage(systemName: "exclamationmark.triangle.fill")
            iconTintColor = .white
            hapticFeedback = .warning

        case .error:
            backgroundColor = .systemRed
            messageTextColor = .white
            actionTextColor = .white
            secondActionTextColor = .white
            icon = icon ?? UIImage(systemName: "xmark.octagon.fill")
            iconTintColor = .white
            hapticFeedback = .error

        case .loading:
            backgroundColor = UIColor.ttgDefaultBackground
            messageTextColor = UIColor.ttgDefaultText
            actionTextColor = UIColor.ttgDefaultText
            secondActionTextColor = UIColor.ttgDefaultText
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            hapticFeedback = .selection
        }
    }

    func announceForAccessibilityIfNeeded() {
        guard shouldAnnounceForAccessibility, UIAccessibility.isVoiceOverRunning else { return }
        let announcement = accessibilityAnnouncement ?? message
        guard !announcement.isEmpty else { return }
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }

    func playHapticFeedback(_ feedback: TTGSnackbarHapticFeedback) {
        switch feedback {
        case .none:
            break
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .lightImpact:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .mediumImpact:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavyImpact:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}

// MARK: - Init configuration.

private extension TTGSnackbar {

    func configure() {
        // Clear subViews
        for subView in subviews {
            subView.removeFromSuperview()
        }

        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(onScreenRotateNotification),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.ttgDefaultBackground
        layer.cornerRadius = cornerRadius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.ttgDefaultShadow.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)

        let contentView = UIView()
        self.contentView = contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = TTGSnackbar.snackbarDefaultFrame
        contentView.backgroundColor = UIColor.clear

        let iconImageView = UIImageView()
        self.iconImageView = iconImageView
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.backgroundColor = iconBackgroundColor
        iconImageView.contentMode = iconContentMode
        iconImageView.tintColor = iconTintColor
        iconImageView.image = icon
        contentView.addSubview(iconImageView)

        let messageLabel = TTGSnackbarLabel()
        self.messageLabel = messageLabel
        messageLabel.accessibilityIdentifier = "messageLabel"
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = UIColor.ttgDefaultText
        messageLabel.font = messageTextFont
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.text = message
        messageLabel.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        contentView.addSubview(messageLabel)

        let actionButton = UIButton()
        self.actionButton = actionButton
        actionButton.accessibilityIdentifier = "actionButton"
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = UIColor.clear
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        actionButton.titleLabel?.font = actionTextFont
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
        actionButton.titleLabel?.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        actionButton.setTitle(actionText, for: UIControl.State())
        actionButton.setImage(actionIcon, for: UIControl.State())
        actionButton.setTitleColor(actionTextColor, for: UIControl.State())
        actionButton.addTarget(self, action: #selector(doAction(_:)), for: .touchUpInside)
        contentView.addSubview(actionButton)

        let secondActionButton = UIButton()
        self.secondActionButton = secondActionButton
        secondActionButton.accessibilityIdentifier = "secondActionButton"
        secondActionButton.translatesAutoresizingMaskIntoConstraints = false
        secondActionButton.backgroundColor = UIColor.clear
        secondActionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        secondActionButton.titleLabel?.font = secondActionTextFont
        secondActionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        secondActionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
        secondActionButton.titleLabel?.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        secondActionButton.setTitle(secondActionText, for: UIControl.State())
        secondActionButton.setImage(secondActionIcon, for: UIControl.State())
        secondActionButton.setTitleColor(secondActionTextColor, for: UIControl.State())
        secondActionButton.addTarget(self, action: #selector(doAction(_:)), for: .touchUpInside)
        contentView.addSubview(secondActionButton)

        let separateView = UIView()
        self.separateView = separateView
        separateView.translatesAutoresizingMaskIntoConstraints = false
        separateView.backgroundColor = separateViewBackgroundColor
        contentView.addSubview(separateView)

        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        self.activityIndicatorView = activityIndicatorView
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = activityIndicatorViewColor
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        contentView.addSubview(activityIndicatorView)

        // Add constraints
        let hConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[iconImageView]-2-[messageLabel]-2-[seperateView(0.5)]-2-[actionButton(>=44@999)]-0-[secondActionButton(>=44@999)]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["iconImageView": iconImageView, "messageLabel": messageLabel, "seperateView": separateView, "actionButton": actionButton, "secondActionButton": secondActionButton])

        let vConstraintsForIconImageView = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-2-[iconImageView]-2-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["iconImageView": iconImageView])

        let vConstraintsForMessageLabel = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[messageLabel]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["messageLabel": messageLabel])

        let vConstraintsForSeperateView = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-4-[seperateView]-4-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["seperateView": separateView])

        let vConstraintsForActionButton = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[actionButton]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["actionButton": actionButton])

        let vConstraintsForSecondActionButton = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[secondActionButton]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["secondActionButton": secondActionButton])

        iconImageViewWidthConstraint = NSLayoutConstraint.init(
            item: iconImageView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: iconImageViewWidth)

        actionButtonMaxWidthConstraint = NSLayoutConstraint.init(
            item: actionButton, attribute: .width, relatedBy: .lessThanOrEqual,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: actionMaxWidth)

        secondActionButtonMaxWidthConstraint = NSLayoutConstraint.init(
            item: secondActionButton, attribute: .width, relatedBy: .lessThanOrEqual,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: actionMaxWidth)

        let vConstraintForActivityIndicatorView = NSLayoutConstraint.init(
            item: activityIndicatorView, attribute: .centerY, relatedBy: .equal,
            toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)

        let hConstraintsForActivityIndicatorView = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[activityIndicatorView]-2-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["activityIndicatorView": activityIndicatorView])

        iconImageView.addConstraint(iconImageViewWidthConstraint!)
        actionButton.addConstraint(actionButtonMaxWidthConstraint!)
        secondActionButton.addConstraint(secondActionButtonMaxWidthConstraint!)

        contentView.addConstraints(hConstraints)
        contentView.addConstraints(vConstraintsForIconImageView)
        contentView.addConstraints(vConstraintsForMessageLabel)
        contentView.addConstraints(vConstraintsForSeperateView)
        contentView.addConstraints(vConstraintsForActionButton)
        contentView.addConstraints(vConstraintsForSecondActionButton)
        contentView.addConstraint(vConstraintForActivityIndicatorView)
        contentView.addConstraints(hConstraintsForActivityIndicatorView)

        messageLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)

        actionButton.setContentHuggingPriority(UILayoutPriority(998), for: .horizontal)
        actionButton.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        secondActionButton.setContentHuggingPriority(UILayoutPriority(998), for: .horizontal)
        secondActionButton.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)

        // add gesture recognizers
        // tap gesture
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapSelf)))

        isAccessibilityElement = false
        accessibilityElements = [messageLabel as Any, actionButton as Any, secondActionButton as Any].compactMap { $0 }

        self.isUserInteractionEnabled = true

        // swipe gestures
        [UISwipeGestureRecognizer.Direction.up, .down, .left, .right].forEach { (direction) in
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeSelf(_:)))
            gesture.direction = direction
            self.addGestureRecognizer(gesture)
        }

        apply(style: style)
    }
}

// MARK: - Actions

private extension TTGSnackbar {

    /**
     Action button callback

     - parameter button: action button
     */
    @objc func doAction(_ button: UIButton) {
        playHapticFeedback(actionHapticFeedback)

        // Call action block first
        button == actionButton ? actionBlock?(self) : secondActionBlock?(self)

        // Show activity indicator
        if duration == .forever && actionButton.isHidden == false {
            actionButton.isHidden = true
            secondActionButton.isHidden = true
            separateView.isHidden = true
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
        } else {
            dismissAnimated(true)
        }
    }

    /// tap callback
    @objc func didTapSelf() {
        playHapticFeedback(.selection)
        self.onTapBlock?(self)
    }

    /**
     Action button callback

     - parameter gesture: the gesture that is sent to the user
     */

    @objc func didSwipeSelf(_ gesture: UISwipeGestureRecognizer) {
        self.onSwipeBlock?(self, gesture.direction)

        if self.shouldDismissOnSwipe {
            if gesture.direction == .right {
                self.animationType = .slideFromLeftToRight
            } else if gesture.direction == .left {
                self.animationType = .slideFromRightToLeft
            } else if gesture.direction == .up {
                self.animationType = .slideFromTopBackToTop
            } else if gesture.direction == .down {
                self.animationType = .slideFromTopBackToTop
            }
            self.dismiss()
        }
    }
}

// MARK: - Rotation notification

private extension TTGSnackbar {
    @objc func onScreenRotateNotification() {
        messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
        layoutIfNeeded()
    }
}


// MARK: - Application lifecycle notification

private extension TTGSnackbar {
    @objc func onApplicationWillResignActive() {
        if pausesDismissTimerWhenAppInactive {
            pauseDismissTimer()
        }
    }

    @objc func onApplicationDidBecomeActive() {
        if pausesDismissTimerWhenAppInactive {
            resumeDismissTimer()
        }
    }
}

// MARK: - Keyboard notification

private extension TTGSnackbar {
    @objc func onKeyboardShow(_ notification: Notification?) {
        if keyboardIsShown {
            return
        }
        keyboardIsShown = true

        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        keyboardHeight = keyboardFrame.cgRectValue.height - safeAreaInsets.bottom

        keyboardHeight += 8
        bottomMargin += keyboardHeight

        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }

    @objc func onKeyboardHide(_ notification: Notification?) {
        if !keyboardIsShown {
            return
        }
        keyboardIsShown = false

        bottomMargin -= keyboardHeight

        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
}

open class TTGSnackbarLabel: UILabel {

    @objc open dynamic var contentInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: contentInset)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(
            top: -contentInset.top,
            left: -contentInset.left,
            bottom: -contentInset.bottom,
            right: -contentInset.right)
        return textRect.inset(by: invertedInsets)
    }

    override open func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }

}

// MARK: TTGSnackbarManager
open class TTGSnackbarManager: NSObject {
    @objc public static let shared = TTGSnackbarManager()
    private override init() {}

    /// The snackbar currently owned by the manager.
    @objc public private(set) weak var currentSnackbar: TTGSnackbar?

    /// Queue to hold pending snackbars.
    private var queuedSnackbars: [TTGSnackbar] = []

    /// Number of snackbars waiting behind the currently visible snackbar.
    @objc public var queuedCount: Int {
        return queuedSnackbars.count
    }

    /// Shows and queues the passed snackbar. Defaults to FIFO queue behavior.
    @objc(showSnackbar:) public func show(snackbar: TTGSnackbar) {
        show(snackbar: snackbar, policy: .enqueue)
    }

    /// Shows a snackbar with an explicit presentation policy.
    @objc(showSnackbar:policy:) public func show(snackbar: TTGSnackbar, policy: TTGSnackbarPresentationPolicy) {
        DispatchQueue.main.async {
            self.enqueue(snackbar, policy: policy)
        }
    }

    /// Dismisses the currently visible snackbar.
    @objc public func dismissCurrent(animated: Bool = true) {
        DispatchQueue.main.async {
            guard let currentSnackbar = self.currentSnackbar else { return }
            animated ? currentSnackbar.dismiss() : currentSnackbar.dismissAnimated(false)
        }
    }

    /// Clears the pending queue and dismisses the current snackbar.
    @objc public func dismissAll(animated: Bool = true) {
        DispatchQueue.main.async {
            self.queuedSnackbars.removeAll()
            guard let currentSnackbar = self.currentSnackbar else { return }
            animated ? currentSnackbar.dismiss() : currentSnackbar.dismissAnimated(false)
        }
    }

    private func enqueue(_ snackbar: TTGSnackbar, policy: TTGSnackbarPresentationPolicy) {
        switch policy {
        case .enqueue:
            queuedSnackbars.append(snackbar)

        case .replaceCurrent:
            queuedSnackbars.removeAll()
            queuedSnackbars.append(snackbar)
            if let currentSnackbar = currentSnackbar {
                currentSnackbar.dismiss()
                return
            }

        case .dropIfShowingSameMessage:
            if currentSnackbar?.message == snackbar.message || queuedSnackbars.contains(where: { $0.message == snackbar.message }) {
                return
            }
            queuedSnackbars.append(snackbar)
        }

        showNextIfNeeded()
    }

    private func showNextIfNeeded() {
        guard currentSnackbar == nil, queuedSnackbars.isEmpty == false else { return }

        let snackbar = queuedSnackbars.removeFirst()
        currentSnackbar = snackbar

        let existingDidDismiss = snackbar.didDismissBlock
        snackbar.didDismissBlock = { [weak self] dismissedSnackbar in
            existingDidDismiss?(dismissedSnackbar)
            guard let self = self else { return }
            if self.currentSnackbar === dismissedSnackbar {
                self.currentSnackbar = nil
            }
            self.showNextIfNeeded()
        }

        snackbar.show()
    }
}
