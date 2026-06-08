//
//  TTGSnackbar.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

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
    @objc open internal(set) dynamic var messageLabel: TTGSnackbarLabel!

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
    @objc open internal(set) dynamic var actionButton: UIButton!

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
    @objc open internal(set) dynamic var secondActionButton: UIButton!

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
    @objc open internal(set) dynamic var iconImageView: UIImageView!

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
    @objc open internal(set) dynamic var activityIndicatorView: UIActivityIndicatorView!

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

    var contentView: UIView!
    var separateView: UIView!

    /// Timer to dismiss the snackbar.
    var dismissTimer: Timer? = nil
    var dismissTimerStartedAt: Date? = nil
    var dismissTimeInterval: TimeInterval = 0
    var remainingDismissTime: TimeInterval? = nil
    var isDismissTimerPaused: Bool = false
    var isDismissing: Bool = false

    /// Keyboard mark
    var keyboardIsShown: Bool = false
    var keyboardHeight: CGFloat = 0

    // Constraints.
    var leftMarginConstraint: NSLayoutConstraint? = nil
    var rightMarginConstraint: NSLayoutConstraint? = nil
    var bottomMarginConstraint: NSLayoutConstraint? = nil
    var topMarginConstraint: NSLayoutConstraint? = nil // Only work when top animation type
    var centerXConstraint: NSLayoutConstraint? = nil

    // Content constraints.
    var iconImageViewWidthConstraint: NSLayoutConstraint? = nil
    var actionButtonMaxWidthConstraint: NSLayoutConstraint? = nil
    var secondActionButtonMaxWidthConstraint: NSLayoutConstraint? = nil

    var contentViewLeftConstraint: NSLayoutConstraint? = nil
    var contentViewRightConstraint: NSLayoutConstraint? = nil
    var contentViewTopConstraint: NSLayoutConstraint? = nil
    var contentViewBottomConstraint: NSLayoutConstraint? = nil

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
