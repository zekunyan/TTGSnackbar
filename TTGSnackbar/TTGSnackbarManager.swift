//
//  TTGSnackbarManager.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit

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
