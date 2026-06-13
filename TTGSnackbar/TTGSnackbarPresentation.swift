//
//  TTGSnackbarPresentation.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

// MARK: - Window lookup.

extension TTGSnackbar {
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

    /**
     Show the snackbar.
     */
    @discardableResult
    @objc func show() -> Bool {
        // Only show once.
        if superview != nil {
            return true
        }

        guard let finalContentView = customContentView ?? contentView else {
            debugPrint("TTGSnackbar needs content to display.")
            return false
        }

        guard let superView = containerView ?? TTGSnackbar.activeWindow else {
            debugPrint("TTGSnackbar needs an active window to display.")
            return false
        }

        NSLayoutConstraint.deactivate(presentationConstraints)
        presentationConstraints.removeAll()

        isDismissing = false
        apply(style: style)

        // Show or hide action button.
        iconImageView.isHidden = icon == nil

        actionButton.isHidden = actionBlock == nil || (actionText.isEmpty && actionIcon == nil)
        secondActionButton.isHidden = secondActionBlock == nil || (secondActionText.isEmpty && secondActionIcon == nil)

        separateView.isHidden = actionButton.isHidden

        iconImageViewWidthConstraint?.constant = iconImageView.isHidden ? 0 : iconImageViewWidth
        actionButtonMaxWidthConstraint?.constant = actionButton.isHidden ? 0 : actionMaxWidth
        secondActionButtonMaxWidthConstraint?.constant = secondActionButton.isHidden ? 0 : actionMaxWidth

        // Content View.
        finalContentView.translatesAutoresizingMaskIntoConstraints = false
        if finalContentView.superview !== self {
            addSubview(finalContentView)
        }

        contentViewTopConstraint = NSLayoutConstraint(item: finalContentView, attribute: .top, relatedBy: .equal,
                                                       toItem: self, attribute: .top, multiplier: 1, constant: contentInset.top)
        contentViewBottomConstraint = NSLayoutConstraint(item: finalContentView, attribute: .bottom, relatedBy: .equal,
                                                          toItem: self, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
        contentViewLeftConstraint = NSLayoutConstraint(item: finalContentView, attribute: .leading, relatedBy: .equal,
                                                        toItem: self, attribute: .leading, multiplier: 1, constant: contentInset.left)
        contentViewRightConstraint = NSLayoutConstraint(item: finalContentView, attribute: .trailing, relatedBy: .equal,
                                                         toItem: self, attribute: .trailing, multiplier: 1, constant: -contentInset.right)

        let contentConstraints = [contentViewTopConstraint!, contentViewBottomConstraint!, contentViewLeftConstraint!, contentViewRightConstraint!]
        addConstraints(contentConstraints)
        presentationConstraints.append(contentsOf: contentConstraints)

        superView.addSubview(self)

        let relativeToItem: Any = shouldHonorSafeAreaLayoutGuides ? superView.safeAreaLayoutGuide : superView

        // Left margin constraint.
        leftMarginConstraint = NSLayoutConstraint(
            item: self, attribute: .leading, relatedBy: .equal,
            toItem: relativeToItem, attribute: .leading, multiplier: 1, constant: leftMargin)

        // Right margin constraint.
        rightMarginConstraint = NSLayoutConstraint(
            item: self, attribute: .trailing, relatedBy: .equal,
            toItem: relativeToItem, attribute: .trailing, multiplier: 1, constant: -rightMargin)

        // Bottom margin constraint.
        bottomMarginConstraint = NSLayoutConstraint(
            item: self, attribute: .bottom, relatedBy: .equal,
            toItem: relativeToItem, attribute: .bottom, multiplier: 1, constant: -bottomMargin)

        // Top margin constraint.
        topMarginConstraint = NSLayoutConstraint(
            item: self, attribute: .top, relatedBy: .equal,
            toItem: relativeToItem, attribute: .top, multiplier: 1, constant: topMargin)

        // Center X constraint.
        centerXConstraint = NSLayoutConstraint(
            item: self, attribute: .centerX, relatedBy: .equal,
            toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)

        // Min height constraint.
        let minHeightConstraint = NSLayoutConstraint(
            item: self, attribute: .height, relatedBy: .greaterThanOrEqual,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarMinHeight)

        // Avoid the "UIView-Encapsulated-Layout-Height" constraint conflicts.
        // http://stackoverflow.com/questions/25059443/what-is-nslayoutconstraint-uiview-encapsulated-layout-height-and-how-should-i
        leftMarginConstraint?.priority = UILayoutPriority(999)
        rightMarginConstraint?.priority = UILayoutPriority(999)
        topMarginConstraint?.priority = UILayoutPriority(999)
        bottomMarginConstraint?.priority = UILayoutPriority(999)
        centerXConstraint?.priority = UILayoutPriority(999)

        if snackbarMaxWidth > 0 {
            centerXConstraint?.isActive = true

            let maxWidthConstraint = widthAnchor.constraint(lessThanOrEqualToConstant: snackbarMaxWidth)
            maxWidthConstraint.priority = UILayoutPriority(999)
            maxWidthConstraint.isActive = true

            let leadingAnchor = shouldHonorSafeAreaLayoutGuides ? superView.safeAreaLayoutGuide.leadingAnchor : superView.leadingAnchor
            let trailingAnchor = shouldHonorSafeAreaLayoutGuides ? superView.safeAreaLayoutGuide.trailingAnchor : superView.trailingAnchor
            let leadingConstraint = self.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: leftMargin)
            let trailingConstraint = self.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -rightMargin)
            leadingConstraint.priority = UILayoutPriority(999)
            trailingConstraint.priority = UILayoutPriority(999)
            leadingConstraint.isActive = true
            trailingConstraint.isActive = true
            presentationConstraints.append(contentsOf: [maxWidthConstraint, leadingConstraint, trailingConstraint])
        } else {
            superView.addConstraint(leftMarginConstraint!)
            superView.addConstraint(rightMarginConstraint!)
            presentationConstraints.append(contentsOf: [leftMarginConstraint!, rightMarginConstraint!])
            leftMarginConstraint?.isActive = shouldActivateLeftAndRightMarginOnCustomContentView ? true : customContentView == nil
            rightMarginConstraint?.isActive = shouldActivateLeftAndRightMarginOnCustomContentView ? true : customContentView == nil
            centerXConstraint?.isActive = customContentView != nil
        }

        superView.addConstraint(bottomMarginConstraint!)
        superView.addConstraint(topMarginConstraint!)
        superView.addConstraint(centerXConstraint!)
        superView.addConstraint(minHeightConstraint)
        presentationConstraints.append(contentsOf: [bottomMarginConstraint!, topMarginConstraint!, centerXConstraint!, minHeightConstraint])

        // Active or deactivate.
        topMarginConstraint?.isActive = false // For top animation.

        willShowBlock?(self)

        // Determine the final display duration and create a dismiss timer when needed.
        let timeInterval = resolvedDisplayDuration()
        if duration != .forever {
            scheduleDismissTimer(timeInterval: timeInterval)
        }

        // Show.
        playHapticFeedback(hapticFeedback)
        showWithAnimation()

        // Accessibility announcement.
        announceForAccessibilityIfNeeded()
        return true
    }

    /**
     Show.
     */
    internal func showWithAnimation() {
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
    internal func dismissAnimated(_ animated: Bool) {
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
    internal func invalidDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        dismissTimerStartedAt = nil
        remainingDismissTime = nil
        isDismissTimerPaused = false
    }
}

// MARK: - Modern behavior helpers.

extension TTGSnackbar {
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
        if duration == .custom {
            guard customDuration > 0 else {
                assertionFailure("TTGSnackbarDuration.custom requires customDuration greater than 0.")
                return TimeInterval(TTGSnackbarDuration.short.rawValue)
            }
            return customDuration
        }

        return TimeInterval(duration.rawValue)
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

        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        activityIndicatorViewWidthConstraint?.constant = 0

        switch style {
        case .default:
            backgroundColor = UIColor.ttgDefaultBackground
            messageTextColor = UIColor.ttgDefaultText
            actionTextColor = UIColor.ttgDefaultText
            secondActionTextColor = UIColor.ttgDefaultText

        case .info:
            backgroundColor = UIColor(red: 20 / 255, green: 126 / 255, blue: 251 / 255, alpha: 1)
            messageTextColor = .white
            actionTextColor = .white
            secondActionTextColor = .white
            hapticFeedback = .selection

        case .success:
            backgroundColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 107 / 255, alpha: 1)
            messageTextColor = .white
            actionTextColor = .white
            secondActionTextColor = .white
            icon = icon ?? UIImage(systemName: "checkmark.circle.fill")
            iconTintColor = .white
            hapticFeedback = .success

        case .warning:
            backgroundColor = UIColor(red: 245 / 255, green: 158 / 255, blue: 11 / 255, alpha: 1)
            messageTextColor = .white
            actionTextColor = .white
            secondActionTextColor = .white
            icon = icon ?? UIImage(systemName: "exclamationmark.triangle.fill")
            iconTintColor = .white
            hapticFeedback = .warning

        case .error:
            backgroundColor = UIColor(red: 239 / 255, green: 68 / 255, blue: 68 / 255, alpha: 1)
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
            activityIndicatorView.color = messageTextColor
            activityIndicatorViewWidthConstraint?.constant = 24
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
