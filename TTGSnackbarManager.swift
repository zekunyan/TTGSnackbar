//
//  TTGSnackbarManager.swift
//  Pods-TTGSnackbarOCExample
//
//  Created by z on 09/10/2019.
//

import Foundation

public enum TTGSnackbarManager {
    private static var lastSnackbarPresentedDate: Double?
    /// This determines the minimum amount of time before you can replace
    private static var currentSnackbar: TTGSnackbar?
    /// a currently presented snackbar with another snackbar of the same message
    public static var shouldAutoReplaceAfterSeconds: Double = 2.5
    
    /// Use this method to automatically handle showing Snackbars one at a time
    /// Notes:
    ///  - This currently only works correctly for message only Snackbars
    ///  - Use `TTGSnackbarManager.show(snackbar)` instead of `snackbar.show()` if you need this functionality
    ///  - Since the `dismissBlock` property is overriden in this method I also added a `dismissBlock` param you can use
    ///
    /// - Parameter snackbar: The snackbar you want to show
    /// - Parameter dismissBlock: The snackbar's dismiss block. Use this instead of `snackbar.dismissBlock = { _ in }`
    public static func show(_ snackbar: TTGSnackbar, dismissBlock: @escaping TTGSnackbar.TTGDismissBlock = { _ in }) {
        let before = self.lastSnackbarPresentedDate ?? 0
        let now = Date().timeIntervalSince1970
        if self.currentSnackbar?.message == snackbar.message {
            if now - before <= self.shouldAutoReplaceAfterSeconds {
                return
            }
        }
        self.currentSnackbar?.dismiss()

        snackbar.dismissBlock = { snackbar in
            dismissBlock(snackbar)
            if snackbar == self.currentSnackbar {
                self.currentSnackbar = nil
                self.lastSnackbarPresentedDate = nil
            }
        }
        snackbar.show()

        self.lastSnackbarPresentedDate = now
        self.currentSnackbar = snackbar
    }
}
