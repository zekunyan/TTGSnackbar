//
//  TTGSnackbarInteractions.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

// MARK: - Actions

extension TTGSnackbar {

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

extension TTGSnackbar {
    @objc func onScreenRotateNotification() {
        messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
        layoutIfNeeded()
    }
}


// MARK: - Application lifecycle notification

extension TTGSnackbar {
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

extension TTGSnackbar {
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

