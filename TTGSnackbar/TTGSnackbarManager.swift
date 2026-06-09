//
//  TTGSnackbarManager.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

enum TTGSnackbarManagerShowResult {
    case accepted
    case dropped
    case failedToPresent
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
    ///
    /// - Returns: `false` when the snackbar was synchronously dropped or could not be presented.
    @discardableResult
    @objc(showSnackbar:) public func show(snackbar: TTGSnackbar) -> Bool {
        return showResult(snackbar: snackbar, policy: .enqueue) == .accepted
    }

    /// Shows a snackbar with an explicit presentation policy.
    ///
    /// - Returns: `false` when the snackbar was synchronously dropped or could not be presented.
    @discardableResult
    @objc(showSnackbar:policy:) public func show(snackbar: TTGSnackbar, policy: TTGSnackbarPresentationPolicy) -> Bool {
        return showResult(snackbar: snackbar, policy: policy) == .accepted
    }

    func showResult(snackbar: TTGSnackbar, policy: TTGSnackbarPresentationPolicy) -> TTGSnackbarManagerShowResult {
        if Thread.isMainThread {
            return enqueue(snackbar, policy: policy)
        }

        DispatchQueue.main.async {
            self.enqueue(snackbar, policy: policy)
        }
        return .accepted
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

    private func enqueue(_ snackbar: TTGSnackbar, policy: TTGSnackbarPresentationPolicy) -> TTGSnackbarManagerShowResult {
        switch policy {
        case .enqueue:
            queuedSnackbars.append(snackbar)

        case .replaceCurrent:
            queuedSnackbars.removeAll()
            queuedSnackbars.append(snackbar)
            if let currentSnackbar = currentSnackbar {
                currentSnackbar.dismiss()
                return .accepted
            }

        case .dropIfShowingSameMessage:
            if currentSnackbar?.message == snackbar.message || queuedSnackbars.contains(where: { $0.message == snackbar.message }) {
                return .dropped
            }
            queuedSnackbars.append(snackbar)
        }

        return showNextIfNeeded() ? .accepted : .failedToPresent
    }

    @discardableResult
    private func showNextIfNeeded() -> Bool {
        guard currentSnackbar == nil, queuedSnackbars.isEmpty == false else { return true }

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

        if !snackbar.show() {
            currentSnackbar = nil
            showNextIfNeeded()
            return false
        }
        return true
    }
}
