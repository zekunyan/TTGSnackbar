//
//  TTGSnackbarAsync.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

// MARK: - Async presentation

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
                switch manager.showResult(snackbar: snackbar, policy: policy) {
                case .accepted:
                    break
                case .dropped:
                    resume(.dropped)
                case .failedToPresent:
                    resume(.failedToPresent)
                }
            } else if !snackbar.show() {
                resume(.failedToPresent)
            }
        }
    }

}
