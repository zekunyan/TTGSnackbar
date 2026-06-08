//
//  TTGSnackbarViewSetup.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

// MARK: - Init configuration.

extension TTGSnackbar {

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
